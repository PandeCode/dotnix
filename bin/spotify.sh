#!/usr/bin/env bash

# Spotify CLI - A command line interface for the Spotify Web API
# Dependencies: curl, jq

# ---------------- Configuration ----------------
CLIENT_ID=""
CLIENT_SECRET=""
REDIRECT_URI="http://127.0.0.1:8888/callback"
AUTH_CODE=""
ACCESS_TOKEN=""
REFRESH_TOKEN=""
TOKEN_EXPIRY=0
CONFIG_FILE="$HOME/.spotify.sh-config"
SPOTIFY_CREDS_FILE="$HOME/.config/spotify_client"
CACHE_DIR="$HOME/.cache/spotify-cli"
CACHE_ENABLED=true
CACHE_TTL=864000 # Cache validity in seconds (240 hours)

# Default options
FORMAT="json" # Format can be "json" or "text"
GET_ALL=false # Whether to get all items by making recursive API calls

# ---------------- Helper Functions ----------------

# Load client credentials from file if available
load_client_credentials() {
	if [ -f "$SPOTIFY_CREDS_FILE" ]; then
		CLIENT_ID=$(head -n 1 "$SPOTIFY_CREDS_FILE")
		CLIENT_SECRET=$(tail -n 1 "$SPOTIFY_CREDS_FILE")
		return 0
	else
		return 1
	fi
}

# Load configuration from file
load_config() {
	if [ -f "$CONFIG_FILE" ]; then
		source "$CONFIG_FILE"
		return 0
	else
		return 1
	fi
}

# Save configuration to file
save_config() {
	cat >"$CONFIG_FILE" <<EOF
CLIENT_ID="$CLIENT_ID"
CLIENT_SECRET="$CLIENT_SECRET"
REDIRECT_URI="$REDIRECT_URI"
AUTH_CODE="$AUTH_CODE"
ACCESS_TOKEN="$ACCESS_TOKEN"
REFRESH_TOKEN="$REFRESH_TOKEN"
TOKEN_EXPIRY=$TOKEN_EXPIRY
EOF
	chmod 600 "$CONFIG_FILE"
}

# Check if credentials are set
check_credentials() {
	if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
		# Try to load from credentials file first
		if load_client_credentials; then
			echo "Loaded credentials from $SPOTIFY_CREDS_FILE"
			save_config
		else
			echo "Error: CLIENT_ID and CLIENT_SECRET must be set"
			echo "Please run: spotify.sh setup"
			exit 1
		fi
	fi
}

# Generate the authorization URL
get_auth_url() {
	local scope="user-read-private user-read-email playlist-read-private playlist-read-collaborative user-library-read user-follow-read user-top-read user-read-recently-played user-read-playback-state user-modify-playback-state user-read-currently-playing"
	echo "https://accounts.spotify.com/authorize?client_id=$CLIENT_ID&response_type=code&redirect_uri=$REDIRECT_URI&scope=${scope// /%20}"
}

# Get new access and refresh tokens using the authorization code
get_tokens_from_code() {
	local response=$(curl -s -X POST "https://accounts.spotify.com/api/token" \
		-H "Content-Type: application/x-www-form-urlencoded" \
		-d "grant_type=authorization_code&code=$AUTH_CODE&redirect_uri=$REDIRECT_URI&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET")

	ACCESS_TOKEN=$(echo "$response" | jq -r '.access_token')
	REFRESH_TOKEN=$(echo "$response" | jq -r '.refresh_token')
	local expires_in=$(echo "$response" | jq -r '.expires_in')
	TOKEN_EXPIRY=$(($(date +%s) + expires_in))

	if [ "$ACCESS_TOKEN" = "null" ]; then
		echo "Error getting tokens: $(echo "$response" | jq -r '.error_description')"
		exit 1
	fi

	save_config
}

# Refresh the access token when it expires
refresh_access_token() {
	local response=$(curl -s -X POST "https://accounts.spotify.com/api/token" \
		-H "Content-Type: application/x-www-form-urlencoded" \
		-d "grant_type=refresh_token&refresh_token=$REFRESH_TOKEN&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET")

	ACCESS_TOKEN=$(echo "$response" | jq -r '.access_token')
	local expires_in=$(echo "$response" | jq -r '.expires_in')
	TOKEN_EXPIRY=$(($(date +%s) + expires_in))

	# Some responses also include a new refresh token
	local new_refresh_token=$(echo "$response" | jq -r '.refresh_token')
	if [ "$new_refresh_token" != "null" ]; then
		REFRESH_TOKEN="$new_refresh_token"
	fi

	if [ "$ACCESS_TOKEN" = "null" ]; then
		echo "Error refreshing token: $(echo "$response" | jq -r '.error_description')"
		exit 1
	fi

	save_config
}

# Ensure we have a valid access token
ensure_access_token() {
	load_config
	check_credentials

	if [ -z "$ACCESS_TOKEN" ] || [ -z "$REFRESH_TOKEN" ]; then
		echo "No valid tokens found. Please authenticate first with 'spotify.sh auth'"
		exit 1
	fi

	# Check if token is expired
	if [ "$(date +%s)" -ge "$TOKEN_EXPIRY" ]; then
		refresh_access_token
	fi
}

# Initialize cache directory
init_cache() {
	if [ "$CACHE_ENABLED" = true ]; then
		mkdir -p "$CACHE_DIR"
	fi
}

# Get cache key (hash of method, endpoint, and any data)
get_cache_key() {
	local method="$1"
	local endpoint="$2"
	local data="$3"
	echo "$method-$endpoint-$data" | md5sum | awk '{print $1}'
}

# Check if cache exists and is valid
check_cache() {
	local cache_key="$1"
	local cache_file="$CACHE_DIR/$cache_key"

	if [ "$CACHE_ENABLED" = false ]; then
		return 1
	fi

	if [ -f "$cache_file" ]; then
		local file_time=$(stat -c %Y "$cache_file")
		local current_time=$(date +%s)
		if [ $((current_time - file_time)) -lt "$CACHE_TTL" ]; then
			return 0
		fi
	fi
	return 1
}

# Get data from cache
get_from_cache() {
	local cache_key="$1"
	cat "$CACHE_DIR/$cache_key"
}

# Save data to cache
save_to_cache() {
	local cache_key="$1"
	local data="$2"

	if [ "$CACHE_ENABLED" = true ]; then
		echo "$data" >"$CACHE_DIR/$cache_key"
	fi
}

# Determine if an endpoint is cacheable
is_cacheable_endpoint() {
	local endpoint="$1"
	local method="$2"

	# Only cache GET requests
	if [ "$method" != "GET" ]; then
		return 1
	fi

	# Don't cache player/playback state endpoints
	if [[ "$endpoint" == */player* ]]; then
		return 1
	fi

	# For now, assume all other GET endpoints are cacheable
	return 0
}

# Make an authenticated request to the Spotify API
spotify_api() {
	local method="$1"
	local endpoint="$2"
	local data="$3"

	ensure_access_token
	init_cache

	local cache_key=$(get_cache_key "$method" "$endpoint" "$data")

	# Check if we can use cached data
	if is_cacheable_endpoint "$endpoint" "$method" && check_cache "$cache_key"; then
		get_from_cache "$cache_key"
		return
	fi

	local curl_cmd="curl -s -X $method"
	curl_cmd+=" -H 'Authorization: Bearer $ACCESS_TOKEN'"

	if [ "$method" = "POST" ] || [ "$method" = "PUT" ]; then
		curl_cmd+=" -H 'Content-Type: application/json'"
		if [ -n "$data" ]; then
			curl_cmd+=" -d '$data'"
		fi
	fi

	curl_cmd+=" 'https://api.spotify.com/v1$endpoint'"

	local response=$(eval "$curl_cmd")

	# Save response to cache if applicable
	if is_cacheable_endpoint "$endpoint" "$method"; then
		save_to_cache "$cache_key" "$response"
	fi

	echo "$response"
}

# Format output based on FORMAT setting
format_output() {
	local json="$1"
	local type="$2" # Type of data: playlists, tracks, artists, etc.

	if [ "$FORMAT" = "json" ]; then
		echo "$json" | jq
	elif [ "$FORMAT" = "text" ]; then
		case "$type" in
		playlists)
			echo "$json" | jq -r '.items[] | "\(.id) | \(.name) | \(.tracks.total) tracks | \(.owner.display_name)"'
			;;
		tracks)
			echo "$json" | jq -r '.items[] | "\(.track.id) | \(.track.name) | \(.track.artists[0].name) | \(.track.album.name)"'
			;;
		playlist_tracks)
			echo "$json" | jq -r '.items[] | "\(.track.id) | \(.track.name) | \(.track.artists[0].name) | \(.track.album.name)"'
			;;
		artists)
			echo "$json" | jq -r '.artists.items[] | "\(.id) | \(.name) | \(.genres[0] // "No genre") | \(.popularity)"'
			;;
		top_artists)
			echo "$json" | jq -r '.items[] | "\(.id) | \(.name) | \(.genres[0] // "No genre") | \(.popularity)"'
			;;
		top_tracks)
			echo "$json" | jq -r '.items[] | "\(.id) | \(.name) | \(.artists[0].name) | \(.album.name)"'
			;;
		devices)
			echo "$json" | jq -r '.devices[] | "\(.id) | \(.name) | \(.type) | \(.is_active)"'
			;;
		search_tracks)
			echo "$json" | jq -r '.tracks.items[] | "\(.id) | \(.name) | \(.artists[0].name) | \(.album.name)"'
			;;
		search_albums)
			echo "$json" | jq -r '.albums.items[] | "\(.id) | \(.name) | \(.artists[0].name) | \(.release_date)"'
			;;
		search_artists)
			echo "$json" | jq -r '.artists.items[] | "\(.id) | \(.name) | \(.genres[0] // "No genre") | \(.popularity)"'
			;;
		search_playlists)
			echo "$json" | jq -r '.playlists.items[] | "\(.id) | \(.name) | \(.tracks.total) tracks | \(.owner.display_name)"'
			;;
		audio_features)
			echo "$json" | jq -r '. | "Energy: \(.energy) | Danceability: \(.danceability) | Acousticness: \(.acousticness) | Instrumentalness: \(.instrumentalness) | Valence: \(.valence) | Tempo: \(.tempo) BPM | Key: \(.key) | Mode: \(.mode) | Time signature: \(.time_signature)"'
			;;
		audio_features_multiple)
			echo "$json" | jq -r '.audio_features[] | "\(.id) | Energy: \(.energy) | Danceability: \(.danceability) | Acousticness: \(.acousticness) | Tempo: \(.tempo) BPM"'
			;;
		*)
			# Fallback to JSON output for unknown types
			echo "$json" | jq
			;;
		esac
	else
		echo "Unknown format: $FORMAT"
		exit 1
	fi
}

# Get all items recursively from a paginated endpoint
get_all_items() {
	local method="$1"
	local base_endpoint="$2"
	local type="$3"
	local limit=${4:-50}

	local offset=0
	local total=1 # Start with 1 to enter the loop
	local all_items='{"items":[]}'

	while [ $offset -lt $total ]; do
		local endpoint="${base_endpoint}?limit=$limit&offset=$offset"
		local response=$(spotify_api "$method" "$endpoint")

		# Extract the total number of items
		total=$(echo "$response" | jq -r '.total')

		# If we couldn't get a total, break
		if [ "$total" = "null" ]; then
			echo "Error: Couldn't get total number of items"
			return 1
		fi

		# Extract items and merge them with our result
		all_items=$(echo "$all_items" | jq --argjson new_items "$(echo "$response" | jq '.items')" '.items += $new_items')

		offset=$((offset + limit))
		echo "Retrieved $offset of $total items..." >&2
	done

	# Reconstruct the response to match the original format but with all items
	local reconstructed=$(echo "$response" | jq --argjson all_items "$(echo "$all_items" | jq '.items')" '.items = $all_items | .limit = $all_items | length | .offset = 0')
	echo "$reconstructed"
}

# ---------------- Command Functions ----------------

# Set up the client ID and secret
cmd_setup() {
	# First try to load from the credentials file
	if load_client_credentials; then
		echo "Loaded credentials from $SPOTIFY_CREDS_FILE"
		CLIENT_ID=$(head -n 1 "$SPOTIFY_CREDS_FILE")
		CLIENT_SECRET=$(tail -n 1 "$SPOTIFY_CREDS_FILE")
		save_config
		echo "Configuration saved to $CONFIG_FILE"
		echo "Next, authenticate with 'spotify.sh auth'"
		return
	fi

	read -p "Enter your Spotify Client ID: " CLIENT_ID
	read -p "Enter your Spotify Client Secret: " CLIENT_SECRET
	save_config

	echo "Configuration saved to $CONFIG_FILE"
	echo "Next, authenticate with 'spotify.sh auth'"
}

# Start the authentication flow
cmd_auth() {
	check_credentials
	local auth_url=$(get_auth_url)
	local auth_temp_file=$(mktemp)

	echo "Please open the following URL in your browser:"
	echo "$auth_url"
	echo
	echo "After authorizing, you will be redirected to a URL that looks like:"
	echo "$REDIRECT_URI?code=XXXX..."
	echo
	read -p "Copy the entire URL you were redirected to: " redirect_url

	# Extract the authorization code from the URL
	AUTH_CODE=$(echo "$redirect_url" | grep -o "code=[^&]*" | cut -d= -f2)

	if [ -z "$AUTH_CODE" ]; then
		echo "Error: Could not extract authorization code from URL"
		exit 1
	fi

	get_tokens_from_code
	echo "Authentication successful!"
}

# Get user profile information
cmd_me() {
	format_output "$(spotify_api "GET" "/me")" "profile"
}

# Get user's playlists
cmd_playlists() {
	local limit=${1:-50}
	local offset=${2:-0}

	if [ "$GET_ALL" = true ]; then
		format_output "$(get_all_items "GET" "/me/playlists" "playlists" "$limit")" "playlists"
	else
		format_output "$(spotify_api "GET" "/me/playlists?limit=$limit&offset=$offset")" "playlists"
	fi
}

# Get a specific playlist
cmd_playlist() {
	if [ -z "$1" ]; then
		echo "Error: Missing playlist ID"
		echo "Usage: spotify.sh playlist <playlist_id>"
		exit 1
	fi

	local playlist_id="$1"
	format_output "$(spotify_api "GET" "/playlists/$playlist_id")" "playlist"
}

# Get tracks from a specific playlist
cmd_playlist_tracks() {
	if [ -z "$1" ]; then
		echo "Error: Missing playlist ID"
		echo "Usage: spotify.sh playlist_tracks <playlist_id> [limit] [offset]"
		exit 1
	fi

	local playlist_id="$1"
	local limit=${2:-50}
	local offset=${3:-0}

	if [ "$GET_ALL" = true ]; then
		format_output "$(get_all_items "GET" "/playlists/$playlist_id/tracks" "playlist_tracks" "$limit")" "playlist_tracks"
	else
		format_output "$(spotify_api "GET" "/playlists/$playlist_id/tracks?limit=$limit&offset=$offset")" "playlist_tracks"
	fi
}

# Get user's saved tracks (liked songs)
cmd_liked_songs() {
	local limit=${1:-50}
	local offset=${2:-0}

	if [ "$GET_ALL" = true ]; then
		format_output "$(get_all_items "GET" "/me/tracks" "tracks" "$limit")" "tracks"
	else
		format_output "$(spotify_api "GET" "/me/tracks?limit=$limit&offset=$offset")" "tracks"
	fi
}

# Get user's followed artists
cmd_artists() {
	local limit=${1:-50}

	format_output "$(spotify_api "GET" "/me/following?type=artist&limit=$limit")" "artists"
}

# Get user's top artists
cmd_top_artists() {
	local limit=${1:-20}
	local time_range=${2:-medium_term} # short_term, medium_term, or long_term

	format_output "$(spotify_api "GET" "/me/top/artists?limit=$limit&time_range=$time_range")" "top_artists"
}

# Get user's top tracks
cmd_top_tracks() {
	local limit=${1:-20}
	local time_range=${2:-medium_term} # short_term, medium_term, or long_term

	format_output "$(spotify_api "GET" "/me/top/tracks?limit=$limit&time_range=$time_range")" "top_tracks"
}

# Get current playback state
cmd_now_playing() {
	format_output "$(spotify_api "GET" "/me/player/currently-playing")" "now_playing"
}

# Get playback devices
cmd_devices() {
	format_output "$(spotify_api "GET" "/me/player/devices")" "devices"
}

# Play a track, album, artist, or playlist
cmd_play() {
	local device_id="$1"
	local uri_type="$2"
	local uri_id="$3"

	if [ -z "$uri_type" ] || [ -z "$uri_id" ]; then
		# Resume playback without specifying context
		if [ -z "$device_id" ]; then
			spotify_api "PUT" "/me/player/play"
		else
			spotify_api "PUT" "/me/player/play?device_id=$device_id"
		fi
		echo "Playback resumed"
		return
	fi

	local json_data
	case "$uri_type" in
	track)
		json_data='{"uris":["spotify:track:'$uri_id'"]}'
		;;
	album)
		json_data='{"context_uri":"spotify:album:'$uri_id'"}'
		;;
	artist)
		json_data='{"context_uri":"spotify:artist:'$uri_id'"}'
		;;
	playlist)
		json_data='{"context_uri":"spotify:playlist:'$uri_id'"}'
		;;
	*)
		echo "Error: Unknown URI type. Use track, album, artist, or playlist."
		exit 1
		;;
	esac

	if [ -z "$device_id" ]; then
		spotify_api "PUT" "/me/player/play" "$json_data"
	else
		spotify_api "PUT" "/me/player/play?device_id=$device_id" "$json_data"
	fi

	echo "Now playing $uri_type: $uri_id"
}

# Pause playback
cmd_pause() {
	local device_id=${1:-""}

	if [ -z "$device_id" ]; then
		spotify_api "PUT" "/me/player/pause"
	else
		spotify_api "PUT" "/me/player/pause?device_id=$device_id"
	fi

	echo "Playback paused"
}

# Skip to next track
cmd_next() {
	local device_id=${1:-""}

	if [ -z "$device_id" ]; then
		spotify_api "POST" "/me/player/next"
	else
		spotify_api "POST" "/me/player/next?device_id=$device_id"
	fi

	echo "Skipped to next track"
}

# Skip to previous track
cmd_previous() {
	local device_id=${1:-""}

	if [ -z "$device_id" ]; then
		spotify_api "POST" "/me/player/previous"
	else
		spotify_api "POST" "/me/player/previous?device_id=$device_id"
	fi

	echo "Skipped to previous track"
}

# Search for tracks, albums, artists, or playlists
cmd_search() {
	local query="$1"
	local type=${2:-"track,album,artist,playlist"}
	local limit=${3:-20}

	if [ -z "$query" ]; then
		echo "Error: Missing search query"
		echo "Usage: spotify.sh search \"query\" [type] [limit]"
		exit 1
	fi

	# URL encode the query
	query=$(echo "$query" | sed 's/ /%20/g')

	local response=$(spotify_api "GET" "/search?q=$query&type=$type&limit=$limit")

	# Format based on search type
	if [[ "$type" == *"track"* ]]; then
		format_output "$response" "search_tracks"
	elif [[ "$type" == *"album"* ]]; then
		format_output "$response" "search_albums"
	elif [[ "$type" == *"artist"* ]]; then
		format_output "$response" "search_artists"
	elif [[ "$type" == *"playlist"* ]]; then
		format_output "$response" "search_playlists"
	else
		format_output "$response" "search"
	fi
}

# Get audio features for a single track
cmd_audio_features() {
	if [ -z "$1" ]; then
		echo "Error: Missing track ID"
		echo "Usage: spotify.sh audio_features <track_id>"
		exit 1
	fi

	local track_id="$1"
	format_output "$(spotify_api "GET" "/audio-features/$track_id")" "audio_features"
}

# Get audio features for multiple tracks
cmd_audio_features_multiple() {
	if [ -z "$1" ]; then
		echo "Error: Missing track IDs"
		echo "Usage: spotify.sh audio_features_multiple <track_id1,track_id2,...>"
		exit 1
	fi

	local track_ids="$1"
	format_output "$(spotify_api "GET" "/audio-features?ids=$track_ids")" "audio_features_multiple"
}

# Get detailed audio analysis for a track
cmd_audio_analysis() {
	if [ -z "$1" ]; then
		echo "Error: Missing track ID"
		echo "Usage: spotify.sh audio_analysis <track_id>"
		exit 1
	fi

	local track_id="$1"
	format_output "$(spotify_api "GET" "/audio-analysis/$track_id")" "audio_analysis"
}

# Cache management functions
cmd_cache_clear() {
	if [ -d "$CACHE_DIR" ]; then
		rm -rf "$CACHE_DIR"/*
		echo "Cache cleared"
	else
		echo "Cache directory does not exist"
	fi
}

cmd_cache_status() {
	if [ -d "$CACHE_DIR" ]; then
		local cache_size=$(du -sh "$CACHE_DIR" | cut -f1)
		local cache_files=$(find "$CACHE_DIR" -type f | wc -l)
		echo "Cache enabled: $CACHE_ENABLED"
		echo "Cache TTL: $CACHE_TTL seconds ($(echo "$CACHE_TTL / 3600" | bc) hours)"
		echo "Cache size: $cache_size"
		echo "Cached files: $cache_files"
	else
		echo "Cache directory does not exist"
		echo "Cache enabled: $CACHE_ENABLED"
	fi
}

cmd_cache_disable() {
	CACHE_ENABLED=false
	echo "Cache disabled for this session"
}

cmd_cache_enable() {
	CACHE_ENABLED=true
	init_cache
	echo "Cache enabled"
}

# Show command usage
cmd_help() {
	echo "Spotify CLI - A command line interface for the Spotify Web API"
	echo
	echo "Usage: spotify.sh [--text] [--all] <command> [arguments]"
	echo
	echo "Global Options:"
	echo "  --text           Output results in simplified text format instead of JSON"
	echo "  --all            Fetch all items for paginated endpoints (might be slow)"
	echo
	echo "Commands:"
	echo "  setup                             Configure your Spotify API credentials"
	echo "  auth                              Authenticate with Spotify"
	echo "  me                                Get your user profile"
	echo "  playlists [limit] [offset]        List your playlists"
	echo "  playlist <playlist_id>            Get details of a specific playlist"
	echo "  playlist_tracks <playlist_id> [limit] [offset]  Get tracks in a playlist"
	echo "  liked_songs [limit] [offset]      List your saved tracks (liked songs)"
	echo "  artists [limit]                   List your followed artists"
	echo "  top_artists [limit] [period]      List your top artists (period: short_term, medium_term, long_term)"
	echo "  top_tracks [limit] [period]       List your top tracks (period: short_term, medium_term, long_term)"
	echo "  now_playing                       Show currently playing track"
	echo "  devices                           List available playback devices"
	echo "  play [device_id] [type] [id]      Start/resume playback, optionally on device and with context"
	echo "                                    (type: track, album, artist, playlist)"
	echo "  pause [device_id]                 Pause playback"
	echo "  next [device_id]                  Skip to next track"
	echo "  previous [device_id]              Skip to previous track"
	echo "  search \"query\" [type] [limit]     Search for items (type: track,album,artist,playlist)"
	echo "  audio_features <track_id>         Get audio features for a track"
	echo "  audio_features_multiple <track_ids>  Get audio features for multiple tracks (comma-separated IDs)"
	echo "  audio_analysis <track_id>         Get detailed audio analysis for a track"
	echo "  cache_status                      Show cache status"
	echo "  cache_clear                       Clear the cache"
	echo "  cache_disable                     Disable caching for this session"
	echo "  cache_enable                      Enable caching"
	echo "  help                              Show this help message"
}

# ---------------- Main ----------------

load_config

# Parse global options
while [[ $# -gt 0 ]]; do
	case "$1" in
	--text)
		FORMAT="text"
		shift
		;;
	--all)
		GET_ALL=true
		shift
		;;
	-*)
		echo "Unknown option: $1"
		cmd_help
		exit 1
		;;
	*)
		break
		;;
	esac
done

# No command provided
if [ $# -eq 0 ]; then
	cmd_help
	exit 0
fi

command="$1"
shift

case "$command" in
setup)
	cmd_setup "$@"
	;;
auth)
	cmd_auth "$@"
	;;
me)
	cmd_me "$@"
	;;
playlists)
	cmd_playlists "$@"
	;;
playlist)
	cmd_playlist "$@"
	;;
playlist_tracks)
	cmd_playlist_tracks "$@"
	;;
liked_songs)
	cmd_liked_songs "$@"
	;;
artists)
	cmd_artists "$@"
	;;
top_artists)
	cmd_top_artists "$@"
	;;
top_tracks)
	cmd_top_tracks "$@"
	;;
now_playing)
	cmd_now_playing "$@"
	;;
devices)
	cmd_devices "$@"
	;;
play)
	cmd_play "$@"
	;;
pause)
	cmd_pause "$@"
	;;
next)
	cmd_next "$@"
	;;
previous)
	cmd_previous "$@"
	;;
search)
	cmd_search "$@"
	;;
audio_features)
	cmd_audio_features "$@"
	;;
audio_features_multiple)
	cmd_audio_features_multiple "$@"
	;;
audio_analysis)
	cmd_audio_analysis "$@"
	;;
cache_status)
	cmd_cache_status "$@"
	;;
cache_clear)
	cmd_cache_clear "$@"
	;;
cache_disable)
	cmd_cache_disable "$@"
	;;
cache_enable)
	cmd_cache_enable "$@"
	;;
help)
	cmd_help "$@"
	;;
test)
	spotify.sh setup
	spotify.sh auth
	spotify.sh --text --all playlists
	spotify.sh liked_songs
	spotify.sh --text --all liked_songs
	spotify.sh --text search "Pusha T" artist
	spotify.sh play "" track 7aK5rlTVxSgcqShPMI1TTH?si=51cbea29f65f496c
	spotify.sh now_playing
	;;
*)
	echo "Unknown command: $command"
	cmd_help
	exit 1
	;;
esac

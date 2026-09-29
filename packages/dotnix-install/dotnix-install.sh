# the target must already be partitioned and mounted at /mnt
if [[ $EUID -ne 0 ]]; then
	exec sudo "$0" "$@"
fi

source=${DOTNIX:-/etc/dotnix}

if ! mountpoint -q /mnt; then
	cat >&2 <<'USAGE'
Mount the machine's root at /mnt first (and its EFI partition at /mnt/boot),
then run this again. For a whole disk with UEFI, for example:

  parted /dev/nvme0n1 -- mklabel gpt
  parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1GiB set 1 esp on
  parted /dev/nvme0n1 -- mkpart root ext4 1GiB 100%
  mkfs.fat -F 32 -n boot /dev/nvme0n1p1
  mkfs.ext4 -L nixos /dev/nvme0n1p2
  mount /dev/disk/by-label/nixos /mnt
  mount --mkdir -o umask=077 /dev/disk/by-label/boot /mnt/boot
USAGE
	exit 1
fi

kind=$(gum choose --header "Install" "one of my machines" "a new machine of mine" "stock NixOS")

if [[ $kind == "stock NixOS" ]]; then
	nixos-generate-config --root /mnt
	"${EDITOR:-nano}" /mnt/etc/nixos/configuration.nix
	nixos-install
	exit 0
fi

repo=$(mktemp -d)/dotnix
cp -r --no-preserve=mode "$source" "$repo"

if [[ $kind == "one of my machines" ]]; then
	host=$(find "$repo/hosts" -mindepth 1 -maxdepth 1 -type d ! -name iso -printf '%f\n' | sort | gum choose --header "Machine")
	user=$(sed -n 's/^ *user = "\(.*\)";/\1/p' "$repo/hosts/$host/default.nix" | head -n 1)
else
	host=$(gum input --header "Machine name" --placeholder "firefly")
	user=$(gum input --header "User" --value "shawn")
	if [[ -e $repo/hosts/$host ]]; then
		echo "hosts/$host already exists; install it as one of my machines" >&2
		exit 1
	fi

	release=$(sed -n 's/^VERSION_ID="\{0,1\}\([0-9.]*\)"\{0,1\}$/\1/p' /etc/os-release)
	mkdir -p "$repo/hosts/$host"
	sed -e "s/@user@/$user/" -e "s/@stateVersion@/$release/" \
		"$HOST_TEMPLATE" >"$repo/hosts/$host/default.nix"

	# into the nixosConfigurations list; nix fmt sorts it later
	awk -v host="$host" '
		/nixosConfigurations = mkHosts/ { inList = 1 }
		inList && /# keep-sorted [e]nd/ { print ""; print "    " host " = { };"; inList = 0 }
		{ print }
	' "$repo/modules/flake/default.nix" >"$repo/flake.tmp"
	mv "$repo/flake.tmp" "$repo/modules/flake/default.nix"
fi

nixos-generate-config --root /mnt --show-hardware-config >"$repo/hosts/$host/hardware.nix"

nixos-install --flake "$repo#$host"

echo "Password for $user:"
nixos-enter --root /mnt -c "passwd $user"

home=/mnt/home/$user
mkdir -p "$home"
rm -rf "$home/dotnix"
cp -r "$repo" "$home/dotnix"
chown -R 1000:100 "$home"

echo "Installed $host. The config is in ~/dotnix; commit hosts/$host when you're back."

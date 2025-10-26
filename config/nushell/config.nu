def tokyo-night [] { return {
    separator: "#a9b1d6"
    leading_trailing_space_bg: { attr: "n" }
    header: { fg: "#9ece6a" attr: "b" }
    empty: "#7aa2f7"
    bool: {|| if $in { "#7dcfff" } else { "light_gray" } }
    int: "#a9b1d6"
    filesize: {|e|
        if $e == 0b {
            "#a9b1d6"
        } else if $e < 1mb {
            "#7dcfff"
        } else {{ fg: "#7aa2f7" }}
    }
    duration: "#a9b1d6"
    date: {|| (date now) - $in |
        if $in < 1hr {
            { fg: "#f7768e" attr: "b" }
        } else if $in < 6hr {
            "#f7768e"
        } else if $in < 1day {
            "#e0af68"
        } else if $in < 3day {
            "#9ece6a"
        } else if $in < 1wk {
            { fg: "#9ece6a" attr: "b" }
        } else if $in < 6wk {
            "#7dcfff"
        } else if $in < 52wk {
            "#7aa2f7"
        } else { "dark_gray" }
    }
    range: "#a9b1d6"
    float: "#a9b1d6"
    string: "#a9b1d6"
    nothing: "#a9b1d6"
    binary: "#a9b1d6"
    cellpath: "#a9b1d6"
    row_index: { fg: "#9ece6a" attr: "b" }
    record: "#a9b1d6"
    list: "#a9b1d6"
    block: "#a9b1d6"
    hints: "dark_gray"
    search_result: { fg: "#f7768e" bg: "#a9b1d6" }

    shape_and: { fg: "#bb9af7" attr: "b" }
    shape_binary: { fg: "#bb9af7" attr: "b" }
    shape_block: { fg: "#7aa2f7" attr: "b" }
    shape_bool: "#7dcfff"
    shape_custom: "#9ece6a"
    shape_datetime: { fg: "#7dcfff" attr: "b" }
    shape_directory: "#7dcfff"
    shape_external: "#7dcfff"
    shape_externalarg: { fg: "#9ece6a" attr: "b" }
    shape_filepath: "#7dcfff"
    shape_flag: { fg: "#7aa2f7" attr: "b" }
    shape_float: { fg: "#bb9af7" attr: "b" }
    shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: "b" }
    shape_globpattern: { fg: "#7dcfff" attr: "b" }
    shape_int: { fg: "#bb9af7" attr: "b" }
    shape_internalcall: { fg: "#7dcfff" attr: "b" }
    shape_list: { fg: "#7dcfff" attr: "b" }
    shape_literal: "#7aa2f7"
    shape_match_pattern: "#9ece6a"
    shape_matching_brackets: { attr: "u" }
    shape_nothing: "#7dcfff"
    shape_operator: "#e0af68"
    shape_or: { fg: "#bb9af7" attr: "b" }
    shape_pipe: { fg: "#bb9af7" attr: "b" }
    shape_range: { fg: "#e0af68" attr: "b" }
    shape_record: { fg: "#7dcfff" attr: "b" }
    shape_redirection: { fg: "#bb9af7" attr: "b" }
    shape_signature: { fg: "#9ece6a" attr: "b" }
    shape_string: "#9ece6a"
    shape_string_interpolation: { fg: "#7dcfff" attr: "b" }
    shape_table: { fg: "#7aa2f7" attr: "b" }
    shape_variable: "#bb9af7"

    background: "#1a1b26"
    foreground: "#c0caf5"
    cursor: "#c0caf5"
}}

let fish_completer = {|spans|
    fish --command $'complete "--do-complete=($spans | str join " ")"'
    | from tsv --flexible --noheaders --no-infer
    | rename value description
}

let carapace_completer = {|spans: list<string>|
	carapace $spans.0 nushell ...$spans
	| from json
	| if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}

let zoxide_completer = {|spans|
	$spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
}


let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -i 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    match $spans.0 {
        # carapace completions are incorrect for nu
        nu => $fish_completer
        # fish completes commits and branch names in a nicer way
        git => $fish_completer
        # carapace doesn't have completions for asdf
        asdf => $fish_completer
        # use zoxide completions for zoxide commands
        __zoxide_z | __zoxide_zi => $zoxide_completer
        _ => $carapace_completer
    } | do $in $spans
}

export def --env cmd [d] { ^mkdir -p $d; cd $d }

def hme [] {
	nvim ~/dotnix/homes/(hostname)/home.nix ;
    nh home switch ~/dotnix;
}

def noe [] {
	nvim ~/dotnix/hosts/(hostname)/configuration.nix ;
    nh os switch ~/dotnix;
}

def cleansys [] {
	^df -h /
	sudo nix-collect-garbage -d
	sudo journalctl --vacuum-time=3d
	go clean --modcache
	^df -h /
}

def cmg [] {
	rm -fr compile_commands.json ;
	cmake -D CMAKE_EXPORT_COMPILE_COMMANDS=ON -S . -B Debug ;
	compdb -p Debug/ list | save compile_commands.json

}

def weather [] {
	curl wttr.in ;
 	curl "wttr.in?format=1" ;
 	curl "wttr.in?format=2";
 	curl "wttr.in?format=3" ;
 	curl "wttr.in?format=4" ;
 	curl wttr.in/moon
}

def zf [] {
	zoxide query --list --score |
	fzf --height 40% --layout reverse --info inline --border --preview "eza --all --group-directories-first --header --long --no-user --no-permissions --color=always {2}" --no-sort |
	awk '{print $2}'
}

$env.config = {
    color_config: (tokyo-night)
	show_banner: false
	edit_mode: vi

	completions: {
		external: {
			enable: true
			max_results: 50
			completer: $external_completer
		}
	}

	filesize: {
		metric: true
	}

	hooks: {
		display_output: "if (term size).columns >= 100 { table -e } else { table }" # run to display the output of a pipeline
		# command_not_found: {
		#   		|cmd_name| (
		#       		# command-not-found $cmd_name
		#   		)
		# } # return an error message when a command is not found
    }

    cursor_shape: {
    	vi_insert: blink_line
    	vi_normal: blink_block
	}
}

# fastfetch

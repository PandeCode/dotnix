$env.config = {
    show_banner: false

    explore: {
        status_bar_background: {fg: "#1D1F21", bg: "#C4C9C6"},
        command_bar_text: {fg: "#C4C9C6"},
        highlight: {fg: "black", bg: "yellow"},
        status: {
            error: {fg: "white", bg: "red"},
            warn: {}
            info: {}
        },
        table: {
            split_line: {fg: "#404040"},
            selected_cell: {bg: light_blue},
            selected_row: {},
            selected_column: {},
        },
    }

    completions: {
        case_sensitive: false # case-sensitive completions
        quick: true    # set to false to prevent auto-selecting completions
        partial: true    # set to false to prevent partial filling of the prompt
        algorithm: "fuzzy"    # prefix or fuzzy
   }

    filesize: {
        metric: true
    }

    edit_mode: vi
    # shell_integration: true # enables terminal shell integration. Off by default, as some terminals have issues with this.

    hooks: {
        pre_prompt: [{ null }] # run before the prompt is shown
        pre_execution: [{ null }] # run before the repl input is run
        env_change: {
            PWD: [{|before, after| null }] # run if the PWD environment is different since the last repl input
        }
        display_output: "if (term size).columns >= 100 { table -e } else { table }" # run to display the output of a pipeline
        command_not_found: {
            |cmd_name| (
                command-not-found $cmd_name
            )
        } # return an error message when a command is not found
    }

    menus: [
        # Configuration for default nushell menus
        # Note the lack of source parameter
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20     # Optional value. If missing all the screen width is used to calculate column width
                col_padding: 2
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: description
                columns: 4
                col_width: 20     # Optional value. If missing all the screen width is used to calculate column width
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
    ]

    keybindings: [
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: history_menu }
        }
        {
            name: help_menu
            modifier: none
            keycode: f1
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: help_menu }
        }
        {
            name: completion_previous_menu
            modifier: shift
            keycode: backtab
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menuprevious }
        }
        {
            name: next_page_menu
            modifier: control
            keycode: char_x
            mode: emacs
            event: { send: menupagenext }
        }
        {
            name: undo_or_previous_page_menu
            modifier: control
            keycode: char_z
            mode: emacs
            event: {
                until: [
                    { send: menupageprevious }
                    { edit: undo }
                ]
            }
        }
        {
            name: escape
            modifier: none
            keycode: escape
            mode: [emacs, vi_normal, vi_insert]
            event: { send: esc }    # NOTE: does not appear to work
        }
        {
            name: cancel_command
            modifier: control
            keycode: char_c
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrlc }
        }
        {
            name: quit_shell
            modifier: control
            keycode: char_d
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrld }
        }
        {
            name: clear_screen
            modifier: control
            keycode: char_l
            mode: [emacs, vi_normal, vi_insert]
            event: { send: clearscreen }
        }
        {
            name: search_history
            modifier: control
            keycode: char_q
            mode: [emacs, vi_normal, vi_insert]
            event: { send: searchhistory }
        }
        {
            name: open_command_editor
            modifier: control
            keycode: char_o
            mode: [emacs, vi_normal, vi_insert]
            event: { send: openeditor }
        }
        {
            name: move_up
            modifier: none
            keycode: up
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {send: menuup}
                    {send: up}
                ]
            }
        }
        {
            name: move_down
            modifier: none
            keycode: down
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {send: menudown}
                    {send: down}
                ]
            }
        }
        {
            name: move_left
            modifier: none
            keycode: left
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {send: menuleft}
                    {send: left}
                ]
            }
        }
        {
            name: move_right_or_take_history_hint
            modifier: none
            keycode: right
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {send: historyhintcomplete}
                    {send: menuright}
                    {send: right}
                ]
            }
        }
        {
            name: move_one_word_left
            modifier: control
            keycode: left
            mode: [emacs, vi_normal, vi_insert]
            event: {edit: movewordleft}
        }
        {
            name: move_one_word_right_or_take_history_hint
            modifier: control
            keycode: right
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {send: historyhintwordcomplete}
                    {edit: movewordright}
                ]
            }
        }
        {
            name: move_to_line_start
            modifier: none
            keycode: home
            mode: [emacs, vi_normal, vi_insert]
            event: {edit: movetolinestart}
        }
        {
            name: move_to_line_start
            modifier: control
            keycode: char_a
            mode: [emacs, vi_normal, vi_insert]
            event: {edit: movetolinestart}
        }
        {
            name: move_to_line_end_or_take_history_hint
            modifier: none
            keycode: end
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {send: historyhintcomplete}
                    {edit: movetolineend}
                ]
            }
        }
        {
            name: move_to_line_end_or_take_history_hint
            modifier: control
            keycode: char_e
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {send: historyhintcomplete}
                    {edit: movetolineend}
                ]
            }
        }
        {
            name: move_to_line_start
            modifier: control
            keycode: home
            mode: [emacs, vi_normal, vi_insert]
            event: {edit: movetolinestart}
        }
        {
            name: move_to_line_end
            modifier: control
            keycode: end
            mode: [emacs, vi_normal, vi_insert]
            event: {edit: movetolineend}
        }
        {
            name: move_up
            modifier: control
            keycode: char_p
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {send: menuup}
                    {send: up}
                ]
            }
        }
        {
            name: move_down
            modifier: control
            keycode: char_t
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {send: menudown}
                    {send: down}
                ]
            }
        }
        {
            name: delete_one_character_backward
            modifier: none
            keycode: backspace
            mode: [emacs, vi_insert]
            event: {edit: backspace}
        }
        {
            name: delete_one_word_backward
            modifier: control
            keycode: backspace
            mode: [emacs, vi_insert]
            event: {edit: backspaceword}
        }
        {
            name: delete_one_character_forward
            modifier: none
            keycode: delete
            mode: [emacs, vi_insert]
            event: {edit: delete}
        }
        {
            name: delete_one_character_forward
            modifier: control
            keycode: delete
            mode: [emacs, vi_insert]
            event: {edit: delete}
        }
        {
            name: delete_one_character_forward
            modifier: control
            keycode: char_h
            mode: [emacs, vi_insert]
            event: {edit: backspace}
        }
        {
            name: delete_one_word_backward
            modifier: control
            keycode: char_w
            mode: [emacs, vi_insert]
            event: {edit: backspaceword}
        }
        {
            name: move_left
            modifier: none
            keycode: backspace
            mode: vi_normal
            event: {edit: moveleft}
        }
        {
            name: newline_or_run_command
            modifier: none
            keycode: enter
            mode: emacs
            event: {send: enter}
        }
        {
            name: move_left
            modifier: control
            keycode: char_b
            mode: emacs
            event: {
                until: [
                    {send: menuleft}
                    {send: left}
                ]
            }
        }
        {
            name: move_right_or_take_history_hint
            modifier: control
            keycode: char_f
            mode: emacs
            event: {
                until: [
                    {send: historyhintcomplete}
                    {send: menuright}
                    {send: right}
                ]
            }
        }
        {
            name: redo_change
            modifier: control
            keycode: char_g
            mode: emacs
            event: {edit: redo}
        }
        {
            name: undo_change
            modifier: control
            keycode: char_z
            mode: emacs
            event: {edit: undo}
        }
        {
            name: paste_before
            modifier: control
            keycode: char_y
            mode: emacs
            event: {edit: pastecutbufferbefore}
        }
        {
            name: cut_word_left
            modifier: control
            keycode: char_w
            mode: emacs
            event: {edit: cutwordleft}
        }
        {
            name: cut_line_to_end
            modifier: control
            keycode: char_k
            mode: emacs
            event: {edit: cuttoend}
        }
        {
            name: cut_line_from_start
            modifier: control
            keycode: char_u
            mode: emacs
            event: {edit: cutfromstart}
        }
        {
            name: swap_graphemes
            modifier: control
            keycode: char_t
            mode: emacs
            event: {edit: swapgraphemes}
        }
        {
            name: move_one_word_left
            modifier: alt
            keycode: left
            mode: emacs
            event: {edit: movewordleft}
        }
        {
            name: move_one_word_right_or_take_history_hint
            modifier: alt
            keycode: right
            mode: emacs
            event: {
                until: [
                    {send: historyhintwordcomplete}
                    {edit: movewordright}
                ]
            }
        }
        {
            name: move_one_word_left
            modifier: alt
            keycode: char_b
            mode: emacs
            event: {edit: movewordleft}
        }
        {
            name: move_one_word_right_or_take_history_hint
            modifier: alt
            keycode: char_f
            mode: emacs
            event: {
                until: [
                    {send: historyhintwordcomplete}
                    {edit: movewordright}
                ]
            }
        }
        {
            name: delete_one_word_forward
            modifier: alt
            keycode: delete
            mode: emacs
            event: {edit: deleteword}
        }
        {
            name: delete_one_word_backward
            modifier: alt
            keycode: backspace
            mode: emacs
            event: {edit: backspaceword}
        }
        {
            name: delete_one_word_backward
            modifier: alt
            keycode: char_m
            mode: emacs
            event: {edit: backspaceword}
        }
        {
            name: cut_word_to_right
            modifier: alt
            keycode: char_d
            mode: emacs
            event: {edit: cutwordright}
        }
        {
            name: upper_case_word
            modifier: alt
            keycode: char_u
            mode: emacs
            event: {edit: uppercaseword}
        }
        {
            name: lower_case_word
            modifier: alt
            keycode: char_l
            mode: emacs
            event: {edit: lowercaseword}
        }
        {
            name: capitalize_char
            modifier: alt
            keycode: char_c
            mode: emacs
            event: {edit: capitalizechar}
        }
    ]
}

# use ~/.cache/starship/init.nu

source ~/.local/share/atuin/init.nu
source ~/.zoxide.nu

source ~/dotnix/config/nushell/alias.nu
source ~/dotnix/config/nushell/theme.nu
source ~/dotnix/config/nushell/completions.nu

def fuck [
    --yes(-y),
    --yeah,
    --hard,
    --repeat(-r),
    --debug(-d)
    --enable-experimental-instant-mode,
    --shell-logger(-l)
    --help(-h),
    --version(-v),
] {
    if $help { thefuck -h; return }
    if $version { thefuck -v; return }

    mut options = []

    if $yes or $yeah or $hard { $options = ($options | append "-y") }
    if $repeat { $options = ($options | append "-r") }
    if $debug { $options = ($options | append "-d") }
    if $enable_experimental_instant_mode { $options = ($options | append "--enable-experimental-instant-mode") }
    if $shell_logger { $options = ($options | append "-l") }

    let options = ($options | str join " ")
    let hist = (history | last 1) | get command.0
    let fuck = $"(TF_ALIAS=fuck PYTHONIOENCODING=utf-8 thefuck $options $hist)"
    nu -e $"($fuck | str replace -a "\r" "" | str replace -a "\n" "")"
}

# fastfetch/

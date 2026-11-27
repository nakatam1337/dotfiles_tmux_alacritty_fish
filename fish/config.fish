source /usr/share/cachyos-fish-config/cachyos-config.fish

# ============================================================
#  Shell greeting  —  a colourful tmux / keybind cheat sheet
# ============================================================
#  Rendered on every interactive fish start. Everything is
#  drawn from the Alt-key bindings in ~/.tmux.conf, so the two
#  files stay in sync in spirit. Colours come from fish's
#  `set_color` (256-colour capable, truecolor on this setup).
#
#  Quick map of the box:
#    cyan   → panes        yellow → windows
#    magenta→ sessions     red    → destructive
#    green  → tips/notes
# ============================================================
function fish_greeting
    # -- palette -------------------------------------------------
    set -l frame (set_color 5f87af) # steel blue frame
    set -l dim (set_color 6c6c6c) # muted separators
    set -l head (set_color --bold ffaf5f)
    set -l key (set_color --bold 5fd7ff) # panes
    set -l wkey (set_color --bold ffd75f) # windows
    set -l skey (set_color --bold ff87d7) # sessions
    set -l rkey (set_color --bold ff5f5f) # destructive
    set -l tip (set_color --bold 87d787) # green
    set -l txt (set_color d0d0d0)
    set -l n (set_color normal)

    # -- little helpers ------------------------------------------
    # pad a key label to a fixed column so descriptions line up
    function __row --no-scope-shadowing
        set -l c $argv[1]
        set -l k $argv[2]
        set -l d $argv[3]
        set -l width 24
        set -l pad (string pad -w $width --right "$k")
        printf '  %s│%s  %s%s%s%s\n' $frame $n $c $pad $n $txt$d
    end
    function __sep --no-scope-shadowing
        printf '  %s├────────────────────────────────────────────────────┤%s\n' $frame $n
    end

    # -- header --------------------------------------------------
    printf '  %s╭────────────────────────────────────────────────────╮%s\n' $frame $n
    printf '  %s│%s  %s✦  tmux%s  %s—  Alt-key bindings, no prefix%s\n' \
        $frame $n $head $n $dim $n
    printf '  %s│%s  %stip:%s hold %sAlt%s and the key — %sC-b%s is still enabled too\n' \
        $frame $n $tip $n $wkey $n $dim $n

    __sep
    printf '  %s│%s  %sPANES%s\n' $frame $n $key $n
    __row $key "Alt h / j / k / l" "move between panes (vim-style)"
    __row $key "Alt \\  ·  Alt -" "split horizontally / vertically"
    __row $key "Alt z" "zoom pane (toggle fullscreen)"
    __row $key "Alt o  ·  Alt ;" "next pane / last active pane"
    __row $key "Alt q" "show pane numbers"
    __row $key "Alt =  ·  H L" "even out layout / swap panes"
    __row $key "Ctrl+Alt h / j / k / l" "resize pane (repeatable)"
    __row $rkey "Alt x" "kill pane"

    __sep
    printf '  %s│%s  %sWINDOWS%s\n' $frame $n $wkey $n
    __row $wkey "Alt c" "new window"
    __row $wkey "Alt n  ·  Alt p" "next / previous window"
    __row $wkey "Alt 1 … 9" "jump to window N"
    __row $wkey "Alt l" "last active window"
    __row $wkey "Alt ,  ·  Alt ." "rename / move window"
    __row $rkey "Alt &" "kill window"

    __sep
    printf '  %s│%s  %sSESSIONS & COPY%s\n' $frame $n $skey $n
    __row $skey "Alt d  ·  Alt D" "detach / detach other clients"
    __row $skey "Alt s  ·  Alt w" "pick session / full tree"
    __row $skey "Alt [  ·  Alt ]" "copy mode / paste buffer"
    __row $skey "Alt :  ·  Alt ?" "command prompt / list all keys"
    __row $skey "Alt r" "reload ~/.tmux.conf"

    printf '  %s╰────────────────────────────────────────────────────╯%s\n' $frame $n

    # -- footer tips ---------------------------------------------
    printf '  %s▸%s %sre-attach after detach:%s %stmux attach%s\n' $tip $n $txt $n $wkey $n
    printf '  %s▸%s %sinside copy mode:%s %svi%s motions, then %sEnter%s copy · %sq%s quit%s\n' \
        $tip $n $txt $n $key $n $txt $n $txt $n $n
end

# ============================================================
#  PATH additions
# ============================================================
set -gx PATH ~/.npm-global/bin $PATH

# Added by Antigravity CLI installer
# set -gx PATH "$HOME/.local/bin" $PATH

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# pnpm
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
    set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end

# opencode
fish_add_path ~/.opencode/bin

# may break some features, we can use:
# # Alias for docker compose with compatible terminal
# alias dc="TERM=xterm-256color docker compose"
# alias dcu="TERM=xterm-256color docker compose up"
# alias dcd="TERM=xterm-256color docker compose down"
#
# NOTE: do NOT force TERM here. Overriding it hides the real terminal's
# capabilities (Alacritty's kitty keyboard protocol → Ctrl+Backspace,
# extended keys in tmux). Let the terminal set TERM itself.
# set -gx TERM xterm-256color
# set -gx LANG en_US.UTF-8
# set -gx LC_ALL en_US.UTF-8

set -gx QT_QPA_PLATFORM "wayland;xcb"

# Basic alias: directly replace tmux with shorter commands
alias t='tmux'
alias ta='tmux attach'
alias tn='tmux new-session'

# Pass parameters: e.g., `tls` lists all sessions
alias tls='tmux list-sessions'

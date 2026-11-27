# dotfiles: tmux · alacritty · fish · helix

My personal terminal setup — tmux driven entirely by **Alt key** bindings
(no `C-b` prefix needed), a colour-matched Alacritty, a fish greeting
that doubles as a keybinding cheat sheet, and a Helix config with a
custom transparent theme.

```
dotfiles_tmux_alacritty_fish/
├── tmux/.tmux.conf            # Alt-key bindings, theme, sane defaults
├── alacritty/alacritty.toml   # terminal config (hyper theme, Shift+C/V copy/paste)
├── fish/config.fish           # PATH setup + colourful tmux greeting
├── helix/config.toml          # editor settings + keymaps (C-s save, soft wrap)
├── helix/languages.toml       # language server / grammar tweaks (rust-analyzer)
├── helix/themes/custom.toml   # papercolor-dark, transparent UI background
└── install.sh                 # copy / symlink into $HOME
```

## Install

```sh
git clone git@github.com:nakatam1337/dotfiles_tmux_alacritty_fish.git
cd dotfiles_tmux_alacritty_fish
./install.sh          # copy, backs up differing files
./install.sh --link   # symlink instead
```

Existing files that differ are saved as `<file>.bak.<timestamp>`.
The Alacritty theme (`~/.config/alacritty/themes`, from
[alacritty-theme](https://github.com/alacritty/alacritty-theme)) is cloned
on first run if missing.

## tmux cheat sheet

`bind -n` puts every binding in the root table, so **hold Alt and press the key**.
The default `C-b` prefix is still available.

| Panes | | Windows | | Sessions & copy | |
|---|---|---|---|---|---|
| `Alt h/j/k/l` | move between panes | `Alt c` | new window | `Alt d` / `Alt D` | detach / detach others |
| `Alt \` / `Alt -` | split h / v | `Alt n` / `Alt p` | next / prev window | `Alt s` / `Alt w` | pick session / full tree |
| `Alt z` | zoom pane | `Alt 1` … `9` | jump to window N | `Alt $` / `Alt ,` | rename session / window |
| `Alt o` / `Alt ;` | next / last pane | `Alt l` | last window | `Alt [` / `Alt ]` | copy mode / paste |
| `Alt q` | pane numbers | `Alt ,` / `Alt .` | rename / move window | `Alt :` / `Alt ?` | command prompt / list keys |
| `Alt =` / `Alt H L` | tile / swap pane | `Alt &` | kill window | `Alt r` | reload config |
| `Ctrl+Alt h/j/k/l` | resize pane | | | `Alt PgUp/PgDn` | scroll output |
| `Alt x` | kill pane | | | | |

Extra settings: `tmux-256color`, extended keys, `set-clipboard on` (copy mode →
system clipboard), windows/panes numbered from 1, `mouse on`, 100k scrollback,
vi copy mode (`v` select, `y` copy).

## fish

The greeting is a colour-coded tmux cheat sheet (panes cyan, windows yellow,
sessions magenta). Needs a truecolour terminal; the rest is standard fish 4.x.

## helix

- `config.toml` sets `theme = "custom"`, block/bar cursor shapes, soft wrap,
  and keymaps: `C-s` write, `C-Space` reload, `R` reload-all.
- `themes/custom.toml` inherits Helix's built-in `papercolor-dark` and renders
  `ui.background` as `none`, so the terminal (and tmux) shows through —
  works nicely with Alacritty's 0.8 opacity.
- `languages.toml` enables rust-analyzer `allFeatures` (leptos) and skips the
  Go grammar set.
- Syntax highlighting is limited to what arrives from the papercolor-dark
  base palette — tweak `themes/custom.toml` to override individual scopes.

## Notes

- Alt = Meta in terminals and arrives as a leading `ESC`; `escape-time 50`
  keeps it snappy.
- **`TERM` matters — never force it.** Alacritty must keep its own terminfo
  entry (`TERM=alacritty`), which advertises the kitty keyboard protocol, so
  tmux can pass modified keys such as Ctrl+Backspace through as CSI-u. Several
  places used to clobber it (`alacritty.toml [env]`, a `set -gx TERM` in
  `config.fish`, and the systemd user environment); all are now removed.
  If a key seems stuck, check `echo $TERM` is `alacritty` (outside tmux) and
  `tmux-256color` (inside), then test with `cat -v` / `fish_key_reader`.
- Kitty-style shells can swallow some Alt keys — bind them in the terminal's
  own config first if a key doesn't reach tmux (`cat -v` is the quick test).

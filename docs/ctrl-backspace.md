# Ctrl+Backspace / Ctrl+Delete — open investigation

**Status: unresolved / parked.** The explicit Alacritty keybindings below are a
working workaround; the "clean" fix is still to be confirmed.

## Symptom

Pressing **Ctrl+Backspace** in fish (inside tmux) does not delete the previous
word. Alacritty's built-in `delete-word` binding does not reach the shell
through tmux.

## The chain

```
Alacritty (TERM=alacritty)  ->  tmux (extended-keys)  ->  fish (TERM=tmux-256color)
```

For Ctrl+Backspace to arrive as a word-delete, the key has to survive **two
hops**:

1. Alacritty → tmux: Alacritty must emit a *distinguishable* sequence
   (CSI-u `\e[127;5u`) instead of plain `^?`.
2. tmux → app: tmux must forward it (needs `extended-keys on` +
   `extended-keys-format csi-u`).

## What we confirmed (ground truth)

- **tmux half works.** Injecting `ESC[127;5u` into a tmux pane
  (`send-keys -t 0 -H 1b 5b 31 32 37 3b 35 75`) and reading the pane via
  control mode (`tmux -C attach`, `%output`) shows the app receives the
  sequence intact: `%output %0 ^[[127;5u`.
- **Alacritty half is the suspect.** Alacritty 0.17 advertises the kitty
  keyboard protocol, but it does **not** emit CSI-u for Ctrl+Backspace on its
  own (default disambiguation is conservative for Backspace). So the terminal
  sends plain `^?` and the Ctrl modifier is lost before tmux ever sees it.
- `TERM` is now correct end to end: `alacritty` outside tmux,
  `tmux-256color` inside. `tput colors` = 256, 256-colour output renders.
  This was *not* sufficient by itself.

## What was tried

| Attempt | Result |
|---|---|
| `set -g extended-keys-format csi-u` + `terminal-features ...:extkeys` | tmux forwards correctly, but nothing arrives as CSI-u |
| Remove `TERM` overrides (`alacritty.toml [env]`, `set -gx TERM` in `config.fish`, `systemctl --user unset-environment TERM`) | `TERM` fixed, key still not working |
| Explicit Alacritty bindings (currently active) | ✅ works |

## Current workaround (active in `alacritty.toml`)

```toml
[[keyboard.bindings]]
key = "Back"
mods = "Control"
chars = "\u001b[127;5u"

[[keyboard.bindings]]
key = "Delete"
mods = "Control"
chars = "\u001b[3;5~"
```

## Open questions / next steps

1. Does Alacritty expose the kitty keyboard protocol reliably to tmux? Test
   with `wezterm`/`kitty` as a control (both send CSI-u natively) to see if
   the failure is Alacritty-specific or tmux-negotiation-specific.
2. Try `set -s extended-keys always` in tmux.
3. Check Alacritty's `keyboard.bindings` docs for `mods = "Control"` +
   `Back` vs. the physical `BSpace` key name.
4. Verify with `fish_key_reader` inside tmux: expect `\e[127;5u`, got `\x7f`.

## Notes / dead ends

- Cannot inject keystrokes in the dev environment (no `wtype`/`ydotool`,
  `/dev/uinput` denied), which is why the Alacritty half could not be
  verified automatically — it needs a human to press the key.
- Unbinding tmux Ctrl bindings is **not** the issue: the only root-table
  bindings are `C-M-h/j/k/l`; nothing binds `C-Backspace` or `C-Delete`.

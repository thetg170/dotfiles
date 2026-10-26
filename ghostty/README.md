# Cursor shader

`effects/cursor_warp.glsl` is a copy of the existing local shader from
[sahaj-b/ghostty-cursor-shaders](https://github.com/sahaj-b/ghostty-cursor-shaders).
The active file is included in this dotfiles repository, so a fresh clone needs
no separate shader download. The legacy downloaded `shaders/` directory is not
tracked or used by the active config; its local files are left untouched.

Edit the constants at the top of `effects/cursor_warp.glsl` to customize duration,
color and thickness. Reload Ghostty with Cmd+Shift+, after editing.

`custom-shader-animation = true` animates focused terminals only. Set it to
`always` if you later enable a pulse/boom shader and need animation while unfocused;
that also keeps background terminal surfaces rendering. Set it to `false` or
comment out `custom-shader` to reduce animation work further.

The config symlink and shader-directory symlink are both handled by `make link`.
The active config still uses Zsh, a maximized window and a hidden titlebar.

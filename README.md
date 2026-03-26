# dotfiles

## init

```bash
bash link.sh
```

Symlinks all files/dirs into `$HOME`, recursing into directories that already exist as real dirs. Skips existing non-symlink files with a warning.

## Tools

| Category | Tools |
|---|---|
| Terminal | WezTerm |
| Shell | zsh, sheldon, zeno, Starship |
| Editor | Neovim, lspmux |
| Git | lazygit |
| AI coding | Claude Code (+ Ghost memory integration) |

## Notes

**WezTerm config path**
```powershell
[Environment]::SetEnvironmentVariable("WEZTERM_CONFIG_FILE", (wsl.exe sh -c 'wslpath -w $(readlink -f ~/.config/wezterm/wezterm.lua)').Trim(), "User")
```

**win32yank**
```bash
curl -LO https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
unzip win32yank-x64.zip -d ~/.local/bin
chmod +x ~/.local/bin/win32yank.exe
```

**rustowl**
```bash
curl -L https://github.com/cordx56/rustowl/releases/download/v1.0.0-rc.1/rustowl-x86_64-unknown-linux-gnu -o ~/.cargo/bin/rustowl
chmod +x ~/.cargo/bin/rustowl
```

## Claude Code + Ghost

Ghost memory integration docs:

```bash
cat ~/.config/claude/ghost/README.md
```

Stop hook automatically stores a short session memory and runs sync (best-effort).

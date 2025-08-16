### 初回クローン
```bash
git clone git@github.com:skitamurra/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 展開
```bash
stow -vt ~ nvim wezterm starship yazi
```

## 設定更新時

1. `~/.config/...` を直接編集する
2. `dotfiles/nvim/.config/...` に反映されていることを確認
3. Git にコミット & プッシュ

## 別端末での展開
```bash
git clone git@github.com:skitamurra/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow -vt ~ nvim wezterm starship yazi
```

---

## 依存ツール

### stow
```bash
sudo apt install stow
```

### win32yank
```bash
sudo apt install unzip
curl -LO https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
unzip win32yank-x64.zip -d ~/.local/bin
chmod +x ~/.local/bin/win32yank.exe
```

### wezterm
```powershell
$w = wsl.exe wslpath -w /home/kitamura/.config/wezterm/wezterm.lua
[Environment]::SetEnvironmentVariable("WEZTERM_CONFIG_FILE", $w.Trim(), "User")
```

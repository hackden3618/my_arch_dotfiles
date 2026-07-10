# my_arch_dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a "package" that gets symlinked into `$HOME`.

## Quick start (Arch Linux)

```bash
# Install core tools
sudo pacman -S git stow

# Clone and enter
git clone git@github.com:hackden3618/my_arch_dotfiles.git ~/dotfiles
cd ~/dotfiles

# Stow each package — this creates symlinks like:
#   ~/.config/hypr  →  ~/dotfiles/hypr/.config/hypr
#   ~/.zshrc        →  ~/dotfiles/zsh/.zshrc
stow hypr waybar nvim gtk kitty wlogout rofi swaync zsh

# Restart Hyprland (super+M or hyprctl reload) to apply config changes
```

## What's tracked

| Package | Symlink target |
|---------|---------------|
| `hypr`  | `~/.config/hypr/`, `~/.config/wallust/` |
| `waybar`| `~/.config/waybar/` |
| `nvim`  | `~/.config/nvim/` |
| `gtk`   | `~/.config/gtk-3.0/`, `~/.config/gtk-4.0/` |
| `kitty` | `~/.config/kitty/` |
| `wlogout`| `~/.config/wlogout/` |
| `rofi`  | `~/.config/rofi/` |
| `swaync`| `~/.config/swaync/` |
| `zsh`   | `~/.zshrc` |

## Essential packages

Install with yay (install yay first if needed):

```bash
sudo pacman -S --needed --noconfirm base-devel git
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay && makepkg -si --noconfirm && cd -
```

### Official repo essentials

```bash
sudo pacman -S --needed --noconfirm \
  hyprland hypridle hyprlock hyprpicker waybar wofi \
  kitty rofi swaync wlogout nwg-look nwg-displays \
  swww wallust-git \
  neovim git lazygit \
  zsh zsh-completions oh-my-zsh-git \
  pipewire pipewire-alsa pipewire-pulse pavucontrol \
  brightnessctl pamixer playerctl \
  ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts \
  polkit-gnome xdg-desktop-portal-hyprland \
  cliphist grim slurp swappy \
  cava fastfetch btop htop \
  jq gum bat eza fd fzf zoxide thefuck \
  networkmanager network-manager-applet bluez-utils blueman \
  gnome-keyring \
  python-pip python-pyquery \
  qt5ct qt6ct kvantum
```

### AUR essentials

```bash
yay -S --needed --noconfirm \
  waybar-git wallust-git \
  wlogout \
  grimblast-git \
  adw-gtk-theme \
  zsh-theme-powerlevel10k-bin-git \
  nwg-dock-hyprland
```

### Icon & cursor themes

```bash
# Kora icon theme
yay -S kora-icon-theme

# ArcAurora cursors
git clone --depth=1 https://github.com/yeyushengfan258/ArcAurora-Cursors.git /tmp/arcaurora
mkdir -p ~/.local/share/icons
cp -pr /tmp/arcaurora/dist ~/.local/share/icons/ArcAurora-cursors
rm -rf /tmp/arcaurora

# Apply with nwg-look (GUI) or gsettings:
gsettings set org.gnome.desktop.interface icon-theme kora
gsettings set org.gnome.desktop.interface cursor-theme ArcAurora-cursors
```

## Post-install

1. **Waybar workspace clicking**: If Hyprland uses the Lua config (`hyprland.lua`), `waybar-git` is required — the stable `waybar` package uses old IPC that doesn't work with Hyprland's Lua protocol.
2. **nwg-displays & monitors**: `monitors.conf` is read by `hyprlua/init.lua` and applied via `hl.monitor()`. Edit `monitors.conf`, then reload Hyprland.
3. **First boot**: `initial-boot.sh` runs once to apply GTK/Qt themes and keyboard layout. It creates a marker (`~/.config/hypr/.initial_startup_done`) to prevent re-running.

## Workflow

```bash
cd ~/dotfiles

# After editing a config, commit to save:
git add -A
git commit -m "describe the change"
git push

# Add a new config directory:
mkdir -p myapp/.config/myapp
mv ~/.config/myapp myapp/.config/
stow myapp
git add myapp
git commit -m "track myapp config"
```

> **Note**: Stow symlinks are one-way — edits to `~/.config/hypr/some-file` write through to `~/dotfiles/hypr/.config/hypr/some-file`. Edits to `~/dotfiles/...` reflect immediately in the live config. No manual re-stowing needed.

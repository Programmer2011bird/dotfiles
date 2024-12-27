sudo pacman -S git
cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

cd .config
git clone https://github.com/Programmer2011bird/dotfiles.git

yay -S tff-jetbrains-mono-nerd neovim oh-my-posh tmux tmux-plugin-manager nautilus rofi qv2ray telegram-desktop udiskie gruvbox-material-gtk-theme-git

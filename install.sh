#!/usr/bin/env bash
# ==========================================
# MyArch Restore Script (bash)
# Запуск: bash restore-myarch.sh
# ==========================================

# Папка бэкапа
BACKUP_DIR="$(pwd)"

# ===============================
# 1️⃣ Установка пакетов
# ===============================
echo "=== Обновляем систему и ставим pacman пакеты ==="
sudo pacman -Syu --needed - < "$BACKUP_DIR/lists/pkglist-pacman.txt"

echo "=== Ставим AUR пакеты ==="

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

if ! command -v yay &>/dev/null; then
    echo "Yay не установлен! Установите yay сначала."
    exit 1
fi
yay -S --needed - < "$BACKUP_DIR/lists/pkglist-aur.txt"

# ===============================
# 2️⃣ Восстановление конфигов
# ===============================
echo "=== Восстанавливаем конфиги ~/.config ==="
mkdir -p ~/.config
cp -r "$BACKUP_DIR/config/"* ~/.config/

# ===============================
# 3️⃣ Kitty
# ===============================
echo "=== Восстанавливаем конфиг Kitty ==="
mkdir -p ~/.config/kitty
cp -r "$BACKUP_DIR/config/kitty/"* ~/.config/kitty/

# ===============================
# 4️⃣ GTK темы и иконки
# ===============================
echo "=== Восстанавливаем GTK темы и иконки ==="
mkdir -p ~/.themes ~/.icons
cp -r "$BACKUP_DIR/extra/themes/"* ~/.themes/
cp -r "$BACKUP_DIR/extra/icons/"* ~/.icons/

# Настройки GTK
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
cp -r "$BACKUP_DIR/config/gtk-3.0/settings.ini" ~/.config/gtk-3.0/
cp -r "$BACKUP_DIR/config/gtk-4.0/settings.ini" ~/.config/gtk-4.0/

# ===============================
# 5️⃣ Hyprland-per-window-layout
# ===============================
echo "=== Восстанавливаем hyprland-per-window-layout ==="
mkdir -p ~/.config/hyprland-per-window-layout
cp -r "$BACKUP_DIR/extra/hyprland-per-window-layout/options.toml" ~/.config/hyprland-per-window-layout/

# ===============================
# 6️⃣ Скрипты и приложения
# ===============================
echo "=== Восстанавливаем скрипты и приложения ==="
mkdir -p ~/scripts
cp -r "$BACKUP_DIR/scripts/"* ~/scripts/
chmod +x ~/scripts/pipes.sh
chmod -R +x ~/scripts/pipes

# ===============================
# 7️⃣ Dotfiles
# ===============================
echo "=== Восстанавливаем dotfiles ==="
cp -r "$BACKUP_DIR/dotfiles/"* ~/

# ===============================
# 8️⃣ Обои и шрифты
# ===============================
echo "=== Восстанавливаем обои и шрифты ==="
mkdir -p ~/Pictures/wallpapers ~/.local/share/fonts
cp -r "$BACKUP_DIR/extra/wallpapers" ~/Pictures/wallpapers
cp -r "$BACKUP_DIR/extra/fonts/"* ~/.local/share/fonts/

# ===============================
# 9️⃣ Настройка fish
# ===============================
echo "=== Настраиваем fish как оболочку по умолчанию ==="
if ! command -v fish &>/dev/null; then
    echo "Fish не установлен! Установите fish сначала."
    exit 1
fi
chsh -s "$(which fish)"

echo "=== Восстановление завершено! Перезапустите сессию или ПК для применения всех настроек ==="

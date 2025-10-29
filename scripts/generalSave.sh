#!/bin/bash

# === save-to-git.sh ===
# Универсальный скрипт для пуша проекта или бэкапа на GitHub.
# Использование:
#   save <local_path> <repo_name> "<commit_message>"
# Флаги:
#   -h, --help   Показать справку

# === Цвета ===
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# === Помощь ===
show_help() {
  echo -e "${YELLOW}Использование:${RESET}"
  echo "  save <local_path> <repo_name> \"commit_message\""
  echo
  echo -e "${YELLOW}Пример:${RESET}"
  echo "  save ~/BackupArch my-backup \"Обновил конфиги Arch\""
  echo
  echo -e "${YELLOW}Описание:${RESET}"
  echo "  Копирует содержимое каталога в GitHub репозиторий, создаёт его если нужно,"
  echo "  делает коммит и пуш."
  echo
  echo -e "${YELLOW}Флаги:${RESET}"
  echo "  -h, --help     Показать эту справку"
  exit 0
}

# === Проверка флагов ===
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  show_help
fi

# === Аргументы ===
LOCAL_PATH="$1"
REPO_NAME="$2"
COMMIT_MESSAGE="$3"

# === Проверка аргументов ===
if [ -z "$LOCAL_PATH" ] || [ -z "$REPO_NAME" ] || [ -z "$COMMIT_MESSAGE" ]; then
  echo -e "${RED}Ошибка:${RESET} недостаточно аргументов."
  echo "Попробуй: save --help"
  exit 1
fi

# === Проверка существования локального пути ===
if [ ! -d "$LOCAL_PATH" ]; then
  echo -e "${RED}Ошибка:${RESET} каталог $LOCAL_PATH не найден!"
  exit 1
fi

# === Проверка авторизации GitHub ===
if ! gh auth status >/dev/null 2>&1; then
  echo -e "${YELLOW}⚠ Не авторизован в GitHub. Запускаю gh auth login...${RESET}"
  gh auth login
fi

# === Папка для локального репозитория ===
REPO_BASE_DIR="$HOME/Repos"
REPO_DIR="$REPO_BASE_DIR/$REPO_NAME"

# === Проверка существования репозитория на GitHub ===
if ! gh repo view "$REPO_NAME" >/dev/null 2>&1; then
  while true; do
    read -p "Репозиторий '$REPO_NAME' не найден на GitHub. Создать новый? [Y/n]: " CONFIRM
    CONFIRM=${CONFIRM:-y}
    case "$CONFIRM" in
      [yY]*)
        echo -e "${GREEN}Создаю новый публичный репозиторий '$REPO_NAME'...${RESET}"
        mkdir -p "$REPO_DIR"
        cd "$REPO_DIR" || exit
        git init
        gh repo create "$REPO_NAME" --public --source=. --remote=origin
        break
        ;;
      [nN]*)
        read -p "Введи корректное имя репозитория: " NEW_REPO_NAME
        REPO_NAME="$NEW_REPO_NAME"
        REPO_DIR="$REPO_BASE_DIR/$REPO_NAME"
        ;;
      *)
        echo "Пожалуйста, введи y (да) или n (нет)."
        ;;
    esac
  done
fi

# === Если локального репозитория нет, создаём ===
if [ ! -d "$REPO_DIR/.git" ]; then
  echo -e "${GREEN}Создаю локальный репозиторий $REPO_NAME...${RESET}"
  mkdir -p "$REPO_DIR"
  cd "$REPO_DIR" || exit
  git init
else
  cd "$REPO_DIR" || exit
fi

# === Копируем содержимое каталога ===
echo -e "${GREEN}Копирую содержимое $LOCAL_PATH в локальный репозиторий...${RESET}"
rsync -a --delete "$LOCAL_PATH"/ "$REPO_DIR"/

# === Добавляем базовый .gitignore, если его нет ===
if [ ! -f "$REPO_DIR/.gitignore" ]; then
  echo -e "${YELLOW}Добавляю базовый .gitignore...${RESET}"
  cat <<EOF > "$REPO_DIR/.gitignore"
# Системные и временные файлы
*.swp
*.swo
*.DS_Store
Thumbs.db
EOF
fi

# === Коммит и пуш ===
git add .
git commit -m "$COMMIT_MESSAGE"
git branch -M main
git push -u origin main

echo -e "${GREEN}✅ Каталог '$LOCAL_PATH' успешно сохранён и запушен в '$REPO_NAME'!${RESET}"

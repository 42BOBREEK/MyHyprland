#!/bin/bash

# === unity-save.sh ===
# Скрипт для быстрого коммита и пуша Unity-проектов на GitHub.
# Использование:
#   save <project_name> <repo_name> "<commit_message>"
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
  echo "  save <project_name> <repo_name> \"commit_message\""
  echo
  echo -e "${YELLOW}Пример:${RESET}"
  echo "  save MyUnityGame myrepo \"Добавил движение игрока\""
  echo
  echo -e "${YELLOW}Описание:${RESET}"
  echo "  Копирует папки Assets, ProjectSettings и Packages из Unity-проекта,"
  echo "  создаёт (или использует) GitHub-репозиторий, коммитит и пушит изменения."
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
PROJECT_NAME="$1"
REPO_NAME="$2"
COMMIT_MESSAGE="$3"

# === Проверка аргументов ===
if [ -z "$PROJECT_NAME" ] || [ -z "$REPO_NAME" ] || [ -z "$COMMIT_MESSAGE" ]; then
  echo -e "${RED}Ошибка:${RESET} недостаточно аргументов."
  echo "Попробуй: save --help"
  exit 1
fi

# === Пути ===
UNITY_PROJECTS_DIR="$HOME/Unity"
REPO_BASE_DIR="$HOME/Documents/GitHub"
REPO_DIR="$REPO_BASE_DIR/$REPO_NAME"
PROJECT_PATH="$UNITY_PROJECTS_DIR/$PROJECT_NAME"

# === Проверка существования Unity-проекта ===
if [ ! -d "$PROJECT_PATH" ]; then
  echo -e "${RED}Ошибка:${RESET} проект $PROJECT_PATH не найден!"
  exit 1
fi

# === Проверка авторизации GitHub ===
if ! gh auth status >/dev/null 2>&1; then
  echo -e "${YELLOW}⚠ Не авторизован в GitHub. Запускаю gh auth login...${RESET}"
  gh auth login
fi

# === Проверка существования репозитория на GitHub ===
if ! gh repo view "$REPO_NAME" >/dev/null 2>&1; then
  while true; do
    read -p "Вы точно правильно написали имя репозитория '$REPO_NAME'? Создать новый? [Y/n]: " CONFIRM
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

# === Создание локального репозитория если его нет ===
if [ ! -d "$REPO_DIR/.git" ]; then
  echo -e "${GREEN}Создаю локальный репозиторий $REPO_NAME...${RESET}"
  mkdir -p "$REPO_DIR"
  cd "$REPO_DIR" || exit
  git init
else
  cd "$REPO_DIR" || exit
fi

# === Проверка папок Unity ===
for folder in Assets ProjectSettings Packages; do
  if [ ! -d "$PROJECT_PATH/$folder" ]; then
    echo -e "${RED}Ошибка:${RESET} папка '$folder' не найдена в проекте $PROJECT_NAME!"
    exit 1
  fi
done

# === Копирование папок Unity ===
echo -e "${GREEN}Копирую папки из Unity проекта...${RESET}"
rsync -a --delete "$PROJECT_PATH/Assets" "$PROJECT_PATH/ProjectSettings" "$PROJECT_PATH/Packages" "$REPO_DIR/"

# === Добавление Unity .gitignore ===
if [ ! -f "$REPO_DIR/.gitignore" ]; then
  echo -e "${YELLOW}Добавляю Unity .gitignore...${RESET}"
  cat <<EOF > "$REPO_DIR/.gitignore"
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
[Ll]ogs/
UserSettings/
MemoryCaptures/
*.csproj
*.sln
*.user
EOF
fi

# === Коммит и пуш ===
git add .
git commit -m "$COMMIT_MESSAGE"
git branch -M main
git push -u origin main

echo -e "${GREEN}✅ Проект '$PROJECT_NAME' успешно сохранён и запушен в '$REPO_NAME'!${RESET}"

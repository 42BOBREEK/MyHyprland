#!/bin/bash

# === showProjects.sh ===
# Показывает все локальные Unity-проекты и GitHub-репозитории.
# Использование:
#   showProjects
# Флаг:
#   -h, --help  Показывает справку по использованию.

# === Цвета ===
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

UNITY_PROJECTS_DIR="$HOME/Unity"
REPOS_DIR="$HOME/Repos"

# === Помощь ===
show_help() {
  echo -e "${YELLOW}Использование:${RESET}"
  echo "  showProjects"
  echo
  echo -e "${YELLOW}Описание:${RESET}"
  echo "  Показывает все Unity-проекты из $UNITY_PROJECTS_DIR и"
  echo "  все локальные репозитории из $REPOS_DIR."
  echo
  echo -e "${YELLOW}Флаги:${RESET}"
  echo "  -h, --help     Показать эту справку"
  exit 0
}

# === Проверка флагов ===
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  show_help
fi

echo -e "${CYAN}=== Unity Projects ===${RESET}"

if [ -d "$UNITY_PROJECTS_DIR" ]; then
  PROJECTS=($(ls -1 "$UNITY_PROJECTS_DIR"))
  if [ ${#PROJECTS[@]} -eq 0 ]; then
    echo -e "${YELLOW}Нет Unity-проектов в $UNITY_PROJECTS_DIR${RESET}"
  else
    for PROJECT in "${PROJECTS[@]}"; do
      echo -e "  ${GREEN}•${RESET} $PROJECT"
    done
  fi
else
  echo -e "${YELLOW}Каталог Unity-проектов ($UNITY_PROJECTS_DIR) не найден.${RESET}"
fi

echo
echo -e "${CYAN}=== Git Repositories ===${RESET}"

if [ -d "$REPOS_DIR" ]; then
  REPOS=($(ls -1 "$REPOS_DIR"))
  if [ ${#REPOS[@]} -eq 0 ]; then
    echo -e "${YELLOW}Нет локальных репозиториев в $REPOS_DIR${RESET}"
  else
    for REPO in "${REPOS[@]}"; do
      echo -e "  ${GREEN}•${RESET} $REPO"
    done
  fi
else
  echo -e "${YELLOW}Каталог репозиториев ($REPOS_DIR) не найден.${RESET}"
fi

echo
echo -e "${CYAN}Готово.${RESET}"

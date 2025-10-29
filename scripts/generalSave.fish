#!/usr/bin/env fish

function print_help
    echo ""
    echo "Использование:"
    echo "  save <папка_источник> <имя_репозитория> <сообщение_коммита>"
    echo ""
    echo "Описание:"
    echo "  Автоматизирует создание локального и публичного репозитория."
    echo ""
    echo "Действия по шагам:"
    echo "  1. Создаёт локальный репозиторий в ~/Repos/<имя_репозитория>"
    echo "  2. Копирует в него файлы из указанной папки"
    echo "  3. Делает коммит с сообщением"
    echo "  4. Создаёт публичный репозиторий на GitHub и пушит туда"
    echo ""
    echo "Пример:"
    echo "  save ~/wallpapers wallpapers \"init commit\""
    echo ""
    echo "Дополнительно:"
    echo "  -h, --help   Показать эту справку"
    echo ""
end

# Проверка аргумента -h или --help
if test (count $argv) -eq 1
    if test $argv[1] = "-h"; or test $argv[1] = "--help"
        print_help
        exit 0
    end
end

# Проверка аргументов
if test (count $argv) -lt 3
    echo "Ошибка: недостаточно аргументов."
    echo "Используйте 'save -h' для справки."
    exit 1
end

set src_dir $argv[1]
set repo_name $argv[2]
set commit_msg $argv[3]
set dest_dir ~/Repos/$repo_name

# Проверка исходной папки
if not test -d $src_dir
    echo "Ошибка: исходная папка '$src_dir' не найдена."
    exit 1
end

# Проверка, существует ли репозиторий на GitHub
gh repo view $repo_name >/dev/null 2>&1
if test $status -ne 0
    echo ""
    echo "Репозиторий '$repo_name' не найден на GitHub."
    read -l -P "Вы уверены, что это правильное имя? (y/n): " answer

    if test "$answer" = "n"
        read -l -P "Введите новое имя репозитория: " new_name
        set repo_name $new_name
        set dest_dir ~/Repos/$repo_name
    end
end

# Создание локальной директории репозитория
mkdir -p $dest_dir

# Удаление всех файлов, только если они есть
set files (ls $dest_dir 2>/dev/null)
if test (count $files) -gt 0
    rm -rf $dest_dir/*
end

# Копирование исходных файлов
cp -r $src_dir/* $dest_dir

cd $dest_dir

# Инициализация git
git init
git add .
git commit -m "$commit_msg"

# Если репозиторий уже есть — просто пушим
gh repo view $repo_name >/dev/null 2>&1
if test $status -eq 0
    echo "Репозиторий '$repo_name' уже существует. Пушим изменения..."
    set username (gh api user --jq '.login')
    # Добавляем remote только если ещё нет
    if not git remote | grep -q origin
        git remote add origin git@github.com:$username/$repo_name.git
    end
    git branch -M main
    git push -u origin main
else
    echo "Создаём новый публичный репозиторий '$repo_name'..."
    gh repo create $repo_name --public --source=. --remote=origin --push
end

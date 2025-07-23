#!/bin/bash

urlify() {
    echo "$1" \
      | tr '[:upper:]' '[:lower:]' \
      | sed -e 's/[^a-z0-9]/-/g' \
            -e 's/--*/-/g' \
            -e 's/^-//' \
            -e 's/-$//'
}

if [ -n "$1" ]; then
    project_name="$1"
else
    read -p "Enter the project name: " project_name
fi
project_dir=$(urlify "$project_name")
base_dir=~/projects
project_path="$base_dir/$project_dir"

if [ -d "$project_path" ]; then
    echo "Error: Directory '$project_path' already exists."
    exit 1
fi

project_types=(Go JavaScript TypeScript C Python Other)
if command -v fzf >/dev/null 2>&1; then
    project_type=$(printf "%s\n" "${project_types[@]}" \
                   | fzf --height=10 --reverse --prompt="Select project type: ")
    if [ $? -ne 0 ] || [ -z "$project_type" ]; then
        echo "Project creation aborted."
        exit 1
    fi
else
    echo "Select the project type:"
    select project_type in "${project_types[@]}"; do
        if [[ " ${project_types[*]} " == *" $project_type "* ]]; then
            break
        else
            echo "Invalid option. Try again or CTRL‑C to abort."
        fi
    done
fi

mkdir -p "$project_path"
cd "$project_path" || exit

echo "# $project_name" > README.md

# base ignore
cat <<EOL > .gitignore
# Env files
.env
.vscode/
EOL

# type‑specific .gitignore additions
case $project_type in
    Go)
        cat <<EOL >> .gitignore
# Go modules & builds
go.sum
/bin/
/pkg/
EOL
        ;;
    JavaScript|TypeScript)
        cat <<EOL >> .gitignore
# Node / TS
node_modules/
dist/
/build/
/*.tsbuildinfo
EOL
        ;;
    C)
        cat <<EOL >> .gitignore
# C objects
*.o
EOL
        ;;
    Python)
        cat <<EOL >> .gitignore
# Python venv & caches
venv/
__pycache__/
/*.py[cod]
EOL
        ;;
    Other)
        echo "# No extra ignore rules" >> .gitignore
        ;;
esac

# scaffold code
case $project_type in
    Go)
        go mod init "$project_dir"
        cat <<EOL > main.go
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
EOL
        ;;
    JavaScript)
        npm init -y
        cat <<EOL > index.js
console.log('Hello, World!');
EOL
        ;;
    TypeScript)
        npm init -y
        npm install --save-dev typescript ts-node @types/node
        npx tsc --init
        mkdir -p src
        cat <<EOL > src/index.ts
console.log('Hello, World!');
EOL
        ;;
    C)
        cat <<EOL > main.c
#include <stdio.h>

int main() {
    printf("Hello, World!\n");
    return 0;
}
EOL
        cat <<EOL > Makefile
CC=gcc
CFLAGS=-Wall -Wextra -std=c11
TARGET=main

all: \$(TARGET)

\$(TARGET): main.o
    \$(CC) \$(CFLAGS) -o \$(TARGET) main.o

main.o: main.c
    \$(CC) \$(CFLAGS) -c main.c

clean:
    rm -f \$(TARGET) *.o

.PHONY: all clean
EOL
        ;;
    Python)
        python3 -m venv venv
        cat <<EOL > main.py
def main():
    print("Hello, World!")

if __name__ == "__main__":
    main()
EOL
        ;;
    Other)
        ;;
esac

read -p "Initialize git repository? [Y/n]: " init_git
if [[ -z "$init_git" || "$init_git" =~ ^[Yy]$ ]]; then
    git init
    git add .
    git commit -m "Initial commit"
    echo "Git repository initialized."
fi

read -p "Open project in tmux session? [y/N]: " open_tmux
if [[ "$open_tmux" =~ ^[Yy]$ ]]; then
    exec "$(dirname "${BASH_SOURCE[0]}")/open_session.sh" "$project_path" "$project_dir"
fi

echo "Project '$project_name' created successfully in '$project_path'."
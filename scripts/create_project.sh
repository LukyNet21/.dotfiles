#!/bin/bash

urlify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]/-/g' -e 's/--*/-/g' -e 's/^-//' -e 's/-$//'
}

read -p "Enter the project name: " project_name

project_dir=$(urlify "$project_name")

base_dir=~/projects

project_path="$base_dir/$project_dir"

if [ -d "$project_path" ]; then
    echo "Error: Directory '$project_path' already exists."
    exit 1
fi

echo "Select the project type:"
select project_type in "Go" "JavaScript" "C" "Other"; do
    case $project_type in
        Go|JavaScript|C|Other)
            break
            ;;
        *)
            echo "Invalid option. Please select a number between 1 and 4."
            ;;
    esac
done

mkdir -p "$project_path"
cd "$project_path" || exit

echo "# $project_name" > README.md

cat <<EOL > .gitignore
# Environment variables
.env

EOL

case $project_type in
    Go)
        cat <<EOL > .gitignore
# Go modules
go.sum

# Go build artifacts
/bin/
/pkg/
EOL
        ;;
    JavaScript)
        cat <<EOL > .gitignore
# Node modules
/node_modules/

# Log files
*.log

# Build artifacts
/dist/
/build/
EOL
        ;;
    C)
        cat <<EOL > .gitignore
# Compiled object files
*.o
EOL
        ;;
    Other)
        echo "# No specific ignore rules for this project type" > .gitignore
        ;;
esac

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
    C)
        cat <<EOL > main.c
#include <stdio.h>

int main() {
    printf("Hello, World!\\n");
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
    Other)
        ;;
esac

git init
git add .
git commit -m "Initial commit"

echo "Project '$project_name' created successfully in '$project_path'."


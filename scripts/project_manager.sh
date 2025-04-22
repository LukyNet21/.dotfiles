#!/bin/bash

PROJECT_DIR=~/projects

if [ -n "$1" ]; then
    project_name="$1"
    selected="$PROJECT_DIR/$project_name"
    if [ ! -d "$selected" ]; then
        echo "Error: '$project_name' not found in $PROJECT_DIR"
        exit 1
    fi
else
    selected=$(find "$PROJECT_DIR" -maxdepth 1 -mindepth 1 -type d | fzf --prompt="Select a project: ")
    if [ -z "$selected" ]; then
        echo "No project selected."
        exit 1
    fi
    project_name=$(basename "$selected")
fi

exec "$(dirname "${BASH_SOURCE[0]}")/open_session.sh" "$selected" "$project_name"


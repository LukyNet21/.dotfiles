#!/bin/bash

PROJECT_DIR=~/projects

selected=$(find "$PROJECT_DIR" -maxdepth 1 -type d | fzf --prompt="Select a project: ")

if [ -z "$selected" ]; then
    echo "No project selected."
    exit 1
fi

project_name=$(basename "$selected")

if tmux has-session -t "$project_name" 2>/dev/null; then
    echo "Attaching to existing tmux session: $project_name"
    tmux attach-session -t "$project_name"
else
    echo "Creating new tmux session: $project_name"
    tmux new-session -d -s "$project_name" -c "$selected"

    tmux rename-window -t "$project_name:1" 'nvim'
    tmux send-keys -t "$project_name:1" 'nvim .' C-m

    tmux new-window -t "$project_name:2" -n 'zsh' -c "$selected"
    tmux send-keys -t "$project_name:2" 'zsh' C-m

    tmux new-window -t "$project_name:3" -n 'lazygit' -c "$selected"
    tmux send-keys -t "$project_name:3" 'lazygit' C-m

    tmux attach-session -t "$project_name:1"
fi


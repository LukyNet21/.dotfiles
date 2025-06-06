#!/bin/bash

sanitize_session_name() {
    echo "$1" \
      | tr '[:upper:]' '[:lower:]' \
      | sed -e 's/[^a-z0-9]/-/g' \
            -e 's/--*/-/g' \
            -e 's/^-//' \
            -e 's/-$//'
}

if [ -n "$1" ]; then
    working_dir=$(realpath "$1")
    if [ ! -d "$working_dir" ]; then
        echo "Error: Directory '$working_dir' does not exist."
        exit 1
    fi
else
    working_dir="$PWD"
fi

current_dir=$(basename "$working_dir")
if [ -n "$2" ]; then
    session_name_raw="$2"
else
    read -p "Enter the tmux session name (leave empty to use '$current_dir'): " session_name_raw
    if [ -z "$session_name_raw" ]; then
        session_name_raw="$current_dir"
    fi
fi

session_name=$(sanitize_session_name "$session_name_raw")

if tmux has-session -t "$session_name" 2>/dev/null; then
    echo "Attaching to existing tmux session: $session_name"
    if [ -n "$TMUX" ]; then
        echo "Switching tmux client to: $session_name"
        tmux switch-client -t "$session_name"
    else
        echo "Attaching to: $session_name"
        tmux attach-session -t "$session_name"
    fi
else
    echo "Creating new tmux session: $session_name"
    tmux new-session -d -s "$session_name" -c "$working_dir"

    tmux rename-window -t "$session_name:1" 'nvim'
    tmux send-keys    -t "$session_name:1" 'nvim .' C-m

    tmux new-window -t "$session_name:2" -n 'zsh'     -c "$working_dir"
    tmux new-window -t "$session_name:3" -n 'lazygit' -c "$working_dir"
    tmux send-keys    -t "$session_name:3" 'lazygit' C-m

    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$session_name:1"
    else
        tmux attach-session -t "$session_name:1"
    fi
fi


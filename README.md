# Dotfiles

Personal configuration files for various tools and environments:

- **kitty** Kitty terminal config & themes  
- **nvim** Neovim configuration (Lazy.nvim, LSP, Telescope, Catppuccin, etc.)  
- **tmux** Tmux config & TPM plugins
- **scripts** Helper shell scripts (project manager, session opener, project initializer)  
- **root** Global dotfiles (`.zshrc`, Powerlevel10k, `.gitconfig`)  

## Installation

Clone the repository including all submodules:

```sh
git clone --recursive https://github.com/LukyNet21/.dotfiles.git ~/.dotfiles
```

## Requirements:
 - zsh:
   - oh-my-posh
   - zoxide
   - fzf
 - tmux:
   - Tmux Plugin Manager


## Usage

- `proj` → run [scripts/project_manager.sh](scripts/project_manager.sh)  
- `mkproj` → run [scripts/create_project.sh](scripts/create_project.sh)  
- `session` → run [scripts/open_session.sh](scripts/open_session.sh)  
## License

This repository is MIT‑licensed. See [LICENSE](LICENSE) for details.

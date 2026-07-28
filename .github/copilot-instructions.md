# Copilot Instructions for Dotfiles Repository

## Repository Overview

This is a personal dotfiles repository that manages configuration for multiple tools and environments:
- **Neovim**: LazyVim-based Lua configuration with plugins and language servers
- **Shell**: Zsh configuration with integrations for modern CLI tools
- **Terminal Multiplexer**: Tmux configuration with plugin manager
- **Editor Configs**: Vim and legacy editor configurations
- **Utilities**: Python helper scripts and Docker setup
- **Package Management**: Homebrew Brewfile for macOS and Linux (via Linuxbrew)

## Setup and Installation

### Running Full Setup
```bash
./setup.sh
```

The setup script handles:
1. OS-specific package installation (macOS vs Linux/apt)
2. Homebrew installation and bundle setup
3. Neovim headless initialization (plugin sync, TreeSitter updates, language servers)
4. Tool-specific configurations (Yazi, Starship, Tmux, etc.)
5. Git global configuration
6. Dotfile linking

### Key Setup Tasks (if modifying setup.sh)
- **Lines 1-24**: OS-specific detection and initial setup
- **Lines 26-52**: Homebrew package manager installation
- **Lines 98-102**: Neovim headless setup (critical for plugin/LSP installation)
- **Lines 105-114**: Final dotfile linking

### Headless Neovim Commands
When modifying Neovim setup, understand these headless operations:
```bash
nvim --headless "+Lazy! sync" +qa          # Install/update all plugins
nvim --headless "+TSUpdate" +qa            # Update TreeSitter parsers
nvim --headless "+MasonInstall <tools>" +qa # Install language servers/formatters
nvim --headless "+MasonUpdate" +qa         # Update installed tools
```

## Neovim Architecture

### Project Structure
```
nvim/
├── init.lua              # Entry point - loads LazyVim and plugins
├── lazy-lock.json        # Plugin version lock file (auto-generated)
├── stylua.toml          # Lua formatter configuration
├── lua/
│   ├── config/
│   │   ├── lazy.lua     # Lazy.nvim setup and plugin loading
│   │   ├── options.lua  # Neovim options and UI settings
│   │   ├── keymaps.lua  # Key mappings
│   │   ├── autocmds.lua # Auto commands
│   │   └── functions/   # Helper functions (markdown, location utilities)
│   └── plugins/         # Individual plugin configurations
└── README.md
```

### Plugin Organization
Each plugin gets its own file in `lua/plugins/`. Example structure:
```lua
return {
  {
    "plugin-author/plugin-name",
    opts = {
      -- plugin configuration
    },
  },
}
```

LazyVim base is imported in `lazy.lua`, so custom plugins leverage its configuration.

### Key Dependencies
- **LazyVim**: Base configuration and defaults
- **Language Servers**: Configured via Mason (see setup.sh line 101)
  - lua-language-server, pyright, clangd, yaml-language-server, etc.
- **Formatters**: 
  - Python: ruff (fix, format, organize imports)
  - Lua: stylua (configured in stylua.toml)
  - Markdown: markdownlint-cli2
  - Shell: shfmt

## Lua Code Conventions

### File Organization
- **lua/config/**: Core configuration (options, keymaps, autocmds)
- **lua/config/functions/**: Reusable helper functions
- **lua/plugins/**: Individual plugin configurations
- Each file should be self-contained and focused on one responsibility

### Plugin Configuration Pattern
```lua
return {
  {
    "plugin-repo",
    opts = { ... },  -- LazyVim will automatically pass these as config
    -- Other spec keys: cmd, keys, event, etc.
  },
}
```

### Comment Style
Use comments sparingly. Include them for:
- Non-obvious LazyVim overrides
- Complex conditional logic
- Japanese comments are acceptable (repo maintainer preference)

### Formatting
- Lua code is formatted with **stylua** (120 column width, 2-space indent)
- Configuration: `nvim/stylua.toml`
- Manual format: `stylua lua/`

## Configuration Files and Their Purpose

### Shell Configuration (.zshrc)
- Sourced by system shell initialization
- Contains environment setup and tool initialization
- Linked to user home directory via setup.sh

### Tmux Configuration (.tmux.conf)
- Plugin manager (tpm) is installed during setup
- Plugins are listed in the config
- Install/update plugins: `~/.tmux/plugins/tpm/bin/install_plugins`

### Tool Configurations (configs/)
- **starship.toml**: Prompt configuration
- **ghostty.config.txt**: Terminal emulator config
- **yazi/**: File manager with keymaps, theme, packages
- **bk/**: Backup-related configuration

### Python Utilities (utils/)
- **md_path.py**: Converts URLs to local documentation paths
- Simple scripts without external dependencies
- Run with: `python utils/md_path.py --path <url> [--name <name>]`

## Docker Setup

The `Dockerfile` provides a containerized development environment:
- **Base**: nvidia/cuda:12.1.1-cudnn8 with Ubuntu 22.04
- **Stages**: Incremental build with apt, Homebrew, packages, Neovim, Tmux
- **Build**: `docker-compose build` (see compose.yml)

When modifying Dockerfile:
- Keep stage order for build cache efficiency
- Test with: `docker-compose build && docker-compose run --rm dotfiles <command>`

## Key Conventions Specific to This Repo

1. **LazyVim-First Approach**: Leverage LazyVim defaults rather than reinventing
2. **Headless Neovim**: All Neovim configuration must be compatible with `nvim --headless` for automation
3. **Symlink Strategy**: Configs are symlinked from dotfiles directory, not copied
4. **Cross-Platform**: Support both macOS (Homebrew) and Linux (Linuxbrew)
5. **Plugin Lock File**: `lazy-lock.json` is committed for reproducible builds
6. **Git Configuration**: Global git settings are applied via setup.sh (merge tool, rebase preference, etc.)

## Common Workflows

### Adding a New Neovim Plugin
1. Create `nvim/lua/plugins/<plugin-name>.lua`
2. Use standard Lazy spec format
3. Test with: `nvim --headless "+Lazy! sync" +qa`
4. Verify it loads: `nvim :Lazy`

### Updating Package Dependencies
1. Modify `Brewfile` with new package
2. Run: `brew bundle install`
3. Update `setup.sh` if the package needs special handling

### Modifying Setup Script
1. Test changes in an isolated environment or Docker container
2. Verify OS detection works (Darwin vs Linux)
3. Ensure all headless Neovim commands complete successfully
4. Commit both setup.sh and any Brewfile changes together

### Editing Shell Configuration
- Changes to `.zshrc` take effect after `source ~/.zshrc` or new shell session
- Test command availability before committing

## Git Configuration

Standard configuration applied automatically via setup.sh:
- Merge tool: `ec` (external editor)
- Pull strategy: `rebase` (no merge commits)
- Rerere: enabled (remember conflict resolutions)
- Fetch: auto-prune
- Editor: `nvim`

## Files to Be Aware Of

- **lazy-lock.json**: Auto-generated by Lazy, should be committed
- **.neoconf.json**: Neovim project config (location-specific)
- **compose.yml**: Docker Compose configuration for containerized setup
- **Brewfile**: Package specifications (DO NOT edit manually without testing)

## Testing and Validation

No formal test suite exists. Validation approaches:
- **Docker**: Full environment test with `docker-compose build`
- **Headless Neovim**: `nvim --headless "+checkhealth" +qa` to validate setup
- **Shell**: `zsh -c "command -v <tool>"` to verify tool availability
- **Manual inspection**: Load Neovim and check `:Lazy`, `:checkhealth`, `:LspInfo`

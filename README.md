# nvim-plugin-template

A template repository for building Neovim plugins with Lua, featuring a complete development environment powered by Nix.

![demo](vhs/demo.gif)

## Features

- Plugin scaffold with `setup()` and a sample user command (`:SampleHello`)
- Testing with [Plenary](https://github.com/nvim-lua/plenary.nvim) + Busted
- Reproducible development environment via [Nix flakes](https://nixos.wiki/wiki/Flakes)
- Code formatting with [treefmt](https://github.com/numtide/treefmt) (stylua, oxfmt, nixfmt)
- Linting with [selene](https://github.com/Kampfkarren/selene)
- Automated git hooks (formatting, linting, secret detection, GitHub Actions security checks)
- Demo recording with [VHS](https://github.com/charmbracelet/vhs)

## Requirements

- [Nix](https://nixos.org/download) with flakes enabled
- [direnv](https://direnv.net)

## Getting Started

1. Click **Use this template** on GitHub to create your repository
2. Rename `sample` to your plugin name throughout the codebase:
   - `lua/sample/` → `lua/<your-plugin>/`
   - `tests/sample/` → `tests/<your-plugin>/`
   - `pname = "sample"` in `flake.nix`
3. Enable the development environment:
   ```bash
   direnv allow
   ```

## Development

```bash
# Enter the development shell
nix develop

# Run tests
nix flake check

# Format all files
nix fmt

# Launch Neovim with the plugin loaded
nix run .#nvim

# Record a demo
nix run .#vhs
```

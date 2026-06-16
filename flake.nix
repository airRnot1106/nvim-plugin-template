{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    # https://github.com/NixOS/nixpkgs/pull/531947
    nixpkgs.url = "github:NixOS/nixpkgs/57e69b6f17cf4d4ad4ed90a31a3b21aa1197d824";
  };

  outputs =
    {
      flake-utils,
      nixpkgs,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        plugin = pkgs.vimUtils.buildVimPlugin {
          pname = "sample";
          version = "dev";
          src = ./.;
          nvimSkipModules = [ "init" ];
          meta = {
            description = "";
            homepage = "";
            license = pkgs.lib.licenses.mit;
            platforms = pkgs.lib.platforms.all;
          };
        };

        nvim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
          plugins = [
            {
              plugin = plugin;
              optional = false;
            }
            {
              plugin = pkgs.vimPlugins.lualine-nvim;
              optional = false;
            }
          ];
          luaRcContent = builtins.readFile ./init.lua;
          wrapRc = true;
          withPython3 = false;
          withRuby = false;
          withNodeJs = false;
          viAlias = false;
          vimAlias = false;
        };

        vhs-script = pkgs.writeShellApplication {
          name = "sample";
          runtimeInputs = with pkgs; [
            bashInteractive
            ffmpeg
            git
            nvim
            ttyd
            vhs
          ];
          text = ''
            cd "$(git rev-parse --show-toplevel)"
            exec vhs vhs/demo.tape
          '';
        };
      in
      {
        devShells = {
          default = pkgs.mkShellNoCC {
            packages = (
              with pkgs;
              [
                neovim
              ]
            );
          };
        };

        packages = {
          default = plugin;
          nvim = nvim;
        };

        apps = {
          vhs = flake-utils.lib.mkApp { drv = vhs-script; } // {
            meta.description = "Run the demo script with vhs";
          };
        };
      }
    );
}

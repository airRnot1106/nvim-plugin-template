{
  inputs = {
    agent-skills = {
      url = "path:./nix/agent-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # https://github.com/NixOS/nixpkgs/pull/531947
    nixpkgs.url = "github:NixOS/nixpkgs/57e69b6f17cf4d4ad4ed90a31a3b21aa1197d824";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      agent-skills,
      flake-utils,
      git-hooks,
      nixpkgs,
      treefmt-nix,
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
        devShells =
          let
            inherit (self.checks.${system}.pre-commit) shellHook enabledPackages;
          in
          {
            default = pkgs.mkShellNoCC {
              inputsFrom = [ agent-skills.devShells.${system}.default ];
              inherit shellHook;
              packages =
                (with pkgs; [
                  neovim
                ])
                ++ enabledPackages;
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

        formatter =
          let
            treefmtEval = treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix;
          in
          treefmtEval.config.build.wrapper;

        checks = {
          pre-commit = git-hooks.lib.${system}.run (
            import ./nix/git-hooks.nix {
              inherit self pkgs;
            }
          );
          test =
            let
              nvim-test = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
                plugins = [
                  {
                    plugin = pkgs.vimPlugins.plenary-nvim;
                    optional = false;
                  }
                ];
                wrapRc = false;
              };
            in
            pkgs.runCommand "test" { nativeBuildInputs = [ nvim-test ]; } ''
              cp -r ${self} source
              chmod -R u+w source
              cd source
              export HOME="$TMPDIR"
              nvim --headless --noplugin -u tests/minimal_init.lua \
                -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua', sequential = true}"
              touch "$out"
            '';
        };
      }
    );
}

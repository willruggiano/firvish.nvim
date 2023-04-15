{
  description = "vim-dirvish but in Lua";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
      ];

      systems = ["x86_64-linux"];
      perSystem = {pkgs, ...}: {
        apps.init.program = pkgs.writeShellApplication {
          name = "init";
          runtimeInputs = with pkgs; [gnused ripgrep];
          text = ''
            mv lua/plugin.lua "lua/$1-firvish.lua"
            rg -l REPLACE_ME | xargs -I{} sed -i s/REPLACE_ME/"$1"/g {}
            git init && git add -A && git commit -am 'chore: initial commit'
            echo 'use flake --impure' > .envrc && direnv allow
            rm doc/.gitkeep
            nix run .#generate-vimdoc
            git add -A && git commit -a --amend --no-edit
            # shellcheck disable=SC2016
            echo '[firvish.nvim] template init done. You can remove `apps.init` from flake.nix now.'
          '';
        };

        apps.generate-vimdoc.program = pkgs.writeShellApplication {
          name = "generate-vimdoc";
          runtimeInputs = with pkgs; [lemmy-help];
          text = ''
            lemmy-help -c lua/REPLACE_ME-firvish.lua > doc/REPLACE_ME-firvish.txt
          '';
        };

        devenv.shells.default = {
          name = "REPLACE_ME.firvish";
          packages = with pkgs; [lemmy-help luajit zk];
          pre-commit.hooks = {
            alejandra.enable = true;
            stylua.enable = true;
          };
        };

        packages.default = pkgs.vimUtils.buildVimPluginFrom2Nix {
          name = "REPLACE_ME.firvish";
          src = ./.;
        };
      };
    };
}

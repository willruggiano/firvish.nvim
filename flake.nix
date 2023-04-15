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
        apps.generate-vimdoc.program = pkgs.writeShellApplication {
          name = "generate-vimdoc";
          runtimeInputs = with pkgs; [lemmy-help];
          text = ''
            lemmy-help -c lua/firvish.lua lua/firvish/extension.lua > doc/firvish.txt
          '';
        };

        devenv.shells.default = {
          name = "firvish.nvim";
          packages = with pkgs; [lemmy-help luajit zk];
          pre-commit.hooks = {
            alejandra.enable = true;
            stylua.enable = true;
          };
        };

        packages.default = pkgs.vimUtils.buildVimPluginFrom2Nix {
          name = "firvish.nvim";
          src = ./.;
        };
      };

      flake = {
        templates = {
          default = {
            path = ./nix/templates/plugin;
            description = "Create a new firvish plugin";
          };
        };
      };
    };
}

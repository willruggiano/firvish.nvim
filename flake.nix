{
  description = "vim-dirvish but in Lua";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.pre-commit-hooks-nix.flakeModule
      ];

      systems = ["x86_64-linux" "aarch64-darwin"];
      perSystem = {
        config,
        pkgs,
        ...
      }: {
        apps.update-docs.program = pkgs.writeShellApplication {
          name = "update-docs";
          runtimeInputs = with pkgs; [lemmy-help];
          text = ''
            lemmy-help lua/firvish.lua > doc/firvish.txt
            lemmy-help -fact lua/firvish/lib.lua lua/firvish/lib/*.lua lua/firvish/types.lua lua/firvish/types/*.lua > doc/firvish-lib.txt
          '';
        };

        devShells.default = pkgs.mkShell {
          name = "firvish.nvim";
          buildInputs = with pkgs; [lemmy-help luajit zk];
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };

        formatter = pkgs.alejandra;

        packages.default = pkgs.vimUtils.buildVimPluginFrom2Nix {
          name = "firvish.nvim";
          src = ./.;
        };

        pre-commit = {
          check.enable = true;
          settings.hooks = {
            alejandra.enable = true;
            stylua.enable = true;
          };
        };
      };
    };
}

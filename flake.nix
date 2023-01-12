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
            lemmy-help lua/firvish.lua lua/firvish/features/*.lua lua/firvish/filetype/*.lua > doc/firvish.txt
            lemmy-help lua/firvish/lib/**/*.lua > doc/firvish-lua-api.txt
            nvim --headless -c 'helptags doc/' -c q
          '';
        };

        devShells.default = pkgs.mkShell {
          name = "firvish.nvim";
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };

        formatter = pkgs.alejandra;

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

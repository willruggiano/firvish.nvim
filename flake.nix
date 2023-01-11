{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      apps.update-docs = flake-utils.lib.mkApp {
        drv = pkgs.writeShellApplication {
          name = "update-docs";
          runtimeInputs = with pkgs; [lemmy-help];
          text = ''
            lemmy-help lua/firvish.lua lua/firvish/config.lua lua/firvish/features/*.lua > doc/firvish.txt && nvim --headless -c 'helptags doc/' -c q
          '';
        };
      };
      devShells.default = pkgs.mkShell {
        name = "dev";
        buildInputs = with pkgs; [lemmy-help];
      };
    });
}

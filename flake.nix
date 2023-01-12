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
            lemmy-help lua/firvish.lua lua/firvish/features/*.lua lua/firvish/filetype/*.lua > doc/firvish.txt
            lemmy-help lua/firvish/lib/**/*.lua > doc/firvish-lua-api.txt
            nvim --headless -c 'helptags doc/' -c q
          '';
        };
      };
      devShells.default = pkgs.mkShell {
        name = "dev";
        buildInputs = with pkgs; [lemmy-help];
      };
    });
}

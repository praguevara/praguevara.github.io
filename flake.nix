{
  description = "Personal website for praguevara";
  # https://www.chrisportela.com/posts/this-site-is-a-flake/

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    utils.url = "github:numtide/flake-utils";
    hugo-theme = {
      url = "github:luizdepra/hugo-coder";
      flake = false;
    };
    hugo-config = {
      url = "git+file:.?file=hugo.toml";
      flake = false;
    };
    content = {
      url = "git+file:.?dir=content";
      flake = false;
    };
    static = {
      url = "git+file:.?dir=static";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, utils, ... }:
    utils.lib.eachSystem [
      utils.lib.system.x86_64-darwin
      utils.lib.system.x86_64-linux
      utils.lib.system.aarch64-darwin
      utils.lib.system.aarch64-linux
    ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        rec {

          packages.website = pkgs.stdenv.mkDerivation {
          name = "website";
          src = self;
          buildInputs = [ pkgs.git pkgs.nodePackages.prettier ];
          buildPhase = ''
            mkdir -p themes
            ln -s ${inputs.hugo-theme} themes/hugo-coder

            # Copy hugo.toml
            cp ${inputs.hugo-config}/hugo.toml hugo.toml
            
            # Copy content directory
            cp -r ${inputs.content}/content/ content/

            # Copy static directory
            cp -r ${inputs.static}/static/ static/

            ${pkgs.hugo}/bin/hugo --logLevel info
            ${pkgs.nodePackages.prettier}/bin/prettier -w public '!**/*.{js,css}'
          '';
          installPhase = ''
            mkdir -p $out
            cp -r public/* $out/
          '';
        };

          defaultPackage = self.packages.${system}.website;

          apps = rec {
            hugo = utils.lib.mkApp { drv = pkgs.hugo; };
            default = hugo;
          };

          devShell =
            pkgs.mkShell { buildInputs = [ pkgs.nixpkgs-fmt pkgs.hugo ]; };
        });
}

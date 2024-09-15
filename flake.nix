{
  description = "Personal website for praguevara";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    utils.url = "github:numtide/flake-utils";
    hugo-theme = {
      url = "github:adityatelange/hugo-PaperMod";
      flake = false;
    };
    # Removed hugo-config, content, and static from inputs
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
          src = self;  # 'self' refers to the flake's source

          buildInputs = [ pkgs.git pkgs.nodePackages.prettier ];

          buildPhase = ''
            mkdir -p themes
            ln -s ${inputs.hugo-theme} themes/PaperMod

            # Copy hugo.toml directly from src
            cp ${self}/hugo.toml hugo.toml

            # Copy content and static directories directly from src
            cp -r ${self}/content/ content/
            cp -r ${self}/static/ static/

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

        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.nixpkgs-fmt pkgs.hugo ];
        };
      });
}

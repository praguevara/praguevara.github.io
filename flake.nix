{
  description = "Personal website for praguevara";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    utils.url = "github:numtide/flake-utils";
    theme = {
      url = "github:welpo/tabi";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      utils,
      ...
    }:
    utils.lib.eachSystem
      [
        utils.lib.system.x86_64-darwin
        utils.lib.system.x86_64-linux
        utils.lib.system.aarch64-darwin
        utils.lib.system.aarch64-linux
      ]
      (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          packages.website = pkgs.stdenv.mkDerivation {
            name = "website";
            src = self; # 'self' refers to the flake's source

            buildInputs = [
              pkgs.nodePackages.prettier
              pkgs.pandoc
              pkgs.zola
              (pkgs.texlive.combine {
                inherit (pkgs.texlive)
                  scheme-basic
                  etoolbox
                  enumitem
                  underscore
                  parskip
                  xcolor
                  sectsty
                  ;
              })
            ];

            buildPhase = ''
              # Generate the PDF from cv.md
              pandoc ${self}/content/cv/cv.md -o static/pablo_ramon_guevara_cv.pdf --template ${self}/jb2resume.latex

              mkdir -p themes
              ln -s ${inputs.theme} themes/tabi

              # Copy config.toml directly from src
              cp ${self}/config.toml config.toml

              cp -r ${self}/content/ content/
              cp -r ${self}/templates/ templates/
              cp -r ${self}/static/ static/

              zola build
              prettier -w public '!**/*.{js,css}'
            '';

            installPhase = ''
              mkdir -p $out
              cp -r public/. $out/
            '';
          };

          defaultPackage = self.packages.${system}.website;

          apps.default = utils.lib.mkApp { drv = self.packages.${system}.website; };

          devShell = pkgs.mkShell {
            buildInputs = [
              pkgs.nixpkgs-fmt
              pkgs.zola
              pkgs.pandoc
              pkgs.nodePackages.prettier
            ];

            shellHook = ''
              mkdir -p themes
              ln -s ${inputs.theme} themes/tabi
            '';
          };
        }
      );
}

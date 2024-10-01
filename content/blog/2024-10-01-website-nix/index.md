+++
title = "How I build my website"
date = "2024-10-01"
+++

My website is made with [Zola](https://www.getzola.org/) and built with a Nix Flake. I also build a PDF version of my [CV](@/cv/index.md) with [Pandoc](https://pandoc.org/) automatically. It's hosted in GitHub pages, and built with a GH action.

I've taken the Nix pill, and while it's sometimes hard to swallow, and the UX isn't great, the benefits are pretty amazing. It allows for everything to be declarative, so the builds are always reproducible.

Since it's a standard Zola project - which uses the [tabi](https://github.com/welpo/tabi) theme, it has `content`, `static`, `templates`, etc... directories, which the command `zola build` uses to build a website and put it in a `public` directory.

This is the `flake.nix` file. A flake, among other things, declares inputs and locks them, so you get reproducibility in your builds.

```nix
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

```

The relevant sections of the flake are:

- **Inputs**: the whole nixpkgs version 24.05, from which I grab prettier, pandoc, zola and texlive. I also use `flake-utils`, and a custom input called `theme`, which points to the `tabi` repository even though it's not a flake.

- **Derivation**: the part that's in between curly brackets after `mkDerivation`. In the buildInputs I define what packages are necessary to build the site. Then, the magic happens in the `buildPhase`, where I generate the CV using pandoc, copy the relevant files and directories and build the site. After it's built, the `installPhase` copies the `public` directory to the `$out` variable, which points to the output of the derivation.

- **Development shell**: this section declares what packages are available and what actions are run when you run the `nix develop` command. This allows me to run `zola serve` to test changes. I also use [direnv](https://direnv.net/) with `use flake;` in my `.envrc`, which runs the command automatically when I cd into it.

When I run a `git push`, the following GitHub action is triggered:

```yaml
name: Build and Deploy to GitHub Pages

on:
  push:
    branches:
      - master
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Install Nix
        uses: cachix/install-nix-action@v27
        with:
          github_access_token: ${{ secrets.GITHUB_TOKEN }}
          nix_path: nixpkgs=channel:nixos-24.05
          extra_nix_config: |
            trusted-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
            substituters = https://hydra.iohk.io https://cache.nixos.org/

      - name: Build Site with Nix
        run: nix build .#website

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./result
          publish_branch: gh-pages
          force_orphan: true

```

It takes 2 minutes to run.

Nix really shines here. Install, run `nix build .#website` and deploy. You always use the same command, regardless of the complexity of the build process.

By the way, I took inspiration from this [post](https://www.chrisportela.com/posts/this-site-is-a-flake/) to create my flake originally. You should give it a look (it's quite short).

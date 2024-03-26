{ pkgs ? import <nixpkgs> { }, system ? builtins.currentSystem }:

let
  # fake opentofu as terraform so that tools like terraform-docs pre-commit hook (which doesn't have tofu support)
  # fall back to tofu
  tofu_terraform =
    pkgs.stdenv.mkDerivation {
      name = "tofu-terraform";
      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out/bin
        echo '#!/usr/bin/env sh' > $out/bin/terraform
        echo 'tofu $@' > $out/bin/terraform
        chmod +x $out/bin/terraform
      '';
    };

  # Fetch the Nix expression from GitHub
  # This will no longer be needed once https://github.com/NixOS/nixpkgs/pull/276695 is merged upstream.
  # What's ugly about this is that we effectively clone the whole of nixpkgs and have to build our own azure cli...
  # This will probably take forever on a GitHub actions runner
  pkgsWithAzFixesSrc = pkgs.fetchFromGitHub {
    owner = "katexochen";
    repo = "nixpkgs";
    rev = "aacf05daec3141ce2bb34fd7c021a86401ac8c51";
    sha256 = "11gdi69l7rdv0im4b1ka4b1gl9jiy6k4fzpk8hd44zss6w5ykhs4"; # update via nix-prefetch-url --unpack https://github.com/...
  };

  # Import the fetched Nix expression
  pkgsWithAzFixes = pkgs.callPackage pkgsWithAzFixesSrc { };

in

pkgs.mkShell {
  NIX_SHELL = "likvid-cloudfoundation";
  shellHook = ''
    echo starting likvid-cloudfoundation dev shell
  '';

  buildInputs = [
    # collie and dependencies
    pkgs.opentofu
    pkgs.terragrunt
    pkgs.tflint
    pkgs.terraform-docs

    # fake tofu as terraform
    tofu_terraform



    # we currently don't have these managed by this collie repo, but will need it soon
    # pkgs.awscli2
    # pkgs.google-cloud-sdk

    # node / typescript for docs
    pkgs.nodejs

    pkgs.pre-commit
  ] ++
  (
    # install the following tools only when not running in CI, because they are already preinstalled/expensive
    if (builtins.getEnv "CI" == "true")
    then 
      [ ]
    else
      [
        (pkgsWithAzFixes.azure-cli.withExtensions [ pkgsWithAzFixes.azure-cli.extensions.account ])
      ]
  );
}

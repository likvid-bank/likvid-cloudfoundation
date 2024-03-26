{ pkgs ? import <nixpkgs> { } }:

let
  # fake opentofu as terraform so that tools like terraform-docs pre-commit hook (which doesn't have tofu support)
  # fall back to tofu
  tofu_terraform =
    pkgs.stdenv.mkDerivation {
      name = "tofu-terraform";
      phases = ["installPhase"];
      installPhase = ''
        mkdir -p $out/bin
        echo '#!/usr/bin/env sh' > $out/bin/terraform
        echo 'tofu $@' > $out/bin/terraform
        chmod +x $out/bin/terraform
      '';
    };

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

    # cloud provider clis
    pkgs.azure-cli

    # we currently don't have these managed by this collie repo, but will need it soon
    # pkgs.awscli2
    # pkgs.google-cloud-sdk

    # node / typescript for docs
    pkgs.nodejs

    pkgs.pre-commit
  ];
}

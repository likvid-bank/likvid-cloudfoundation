{ pkgs ? import <nixpkgs> { }, unstable ? import <nixpkgs-unstable> { } }:

pkgs.mkShell {
  NIX_SHELL = "likvid-cloudfoundation";
  shellHook = ''
    echo starting likvid-cloudfoundation dev shell
  '';

  buildInputs = [
    # collie and dependencies
    unstable.terraform
    unstable.terragrunt
    unstable.tflint
    unstable.terraform-docs

    # cloud provider clis
    pkgs.awscli2
    pkgs.azure-cli
    pkgs.google-cloud-sdk

    # node / typescript for docs
    pkgs.nodejs
  ];
}

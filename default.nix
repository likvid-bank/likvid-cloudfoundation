{ pkgs ? import <nixpkgs> { }, unstable ? import <nixpkgs-unstable> { } }:

pkgs.mkShell {
  NIX_SHELL = "likvid-cloudfoundation";
  shellHook = ''
    echo starting likvid-cloudfoundation dev shell
  '';

  buildInputs = [
    # collie and dependencies
    pkgs.terraform
    unstable.terragrunt
    unstable.tflint
    unstable.terraform-docs

    # cloud provider clis
    pkgs.azure-cli
    
    # we currently don't have these managed by this collie repo, but will need it soon
    # pkgs.awscli2
    # pkgs.google-cloud-sdk

    # node / typescript for docs
    pkgs.nodejs
  ];
}

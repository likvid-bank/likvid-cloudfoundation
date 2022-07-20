{ pkgs ? import <nixpkgs-unstable> { } }:

pkgs.mkShell {
  NIX_SHELL = "likvid-cloudfoundation";
  shellHook = ''
    echo starting likvid-cloudfoundation dev shell
  '';

  buildInputs = [
    pkgs.deno

    # terraform
    pkgs.terraform
    pkgs.terragrunt
    pkgs.tflint
    pkgs.terraform-docs

    # cloud provider clis
    pkgs.awscli2
    pkgs.azure-cli
    pkgs.google-cloud-sdk

    # script dependencies
    pkgs.gnused # sed acts inconsistently on macOS, so we always use GNU sed
    pkgs.rsync
    pkgs.jq
    
    # node / typescript for docs
    pkgs.nodejs-16_x
    (pkgs.yarn.override {
        nodejs = pkgs.nodejs-16_x;
    })
  ];
}

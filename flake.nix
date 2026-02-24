{
  description = "Flake for likvid-cloudfoundation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };


  outputs = { self, nixpkgs, nixpkgs-unstable }:

    let
      # These tools are pre-installed in github actions, so we can save the time for installing them.
      # This can save as much as 20s (with nix on tmpfs), trading some consistency for perf.
      github_actions_preinstalled = pkgs:
        with pkgs;
        [
          awscli2
          (azure-cli.withExtensions [ azure-cli.extensions.account ])
          nodejs

          # note: google cloud sdk is not preinstalled in github actions
        ];

      # core packasges required in CI and not preinstalled in github actions
      core_packages = pkgs: pkgsUnstable:
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
        in
        with pkgs;
        [
          # terraform tools
          pkgsUnstable.opentofu
          terragrunt
          tflint
          tfupdate
          terraform-docs

          # fake tofu as terraform
          tofu_terraform

          # cli tools not already pre-installed
          google-cloud-sdk # we authenticate to GCP via the specific github action

          # script dependencies
          gnused # sed acts inconsistently on macOS, so we always use GNU sed
          jq
          pre-commit
        ];

      # packages not preinstalled in github actions and necessary outside of CI
      developer_packages = pkgs:
        with pkgs;
        [
          # cloud platforms currently not deployed by CI
          kubelogin # for AKS

          # needed to access secrets
          vault-bin
        ];


      importNixpkgsUnstable = system:
        import nixpkgs-unstable { inherit system; };

      importNixpkgs = system:
        import nixpkgs
          {
            inherit system;
            config = {
              allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
                "vault-bin" # vault uses bsl-11 which is unfree
              ];
            };
          };

      defaultShellForSystem = system:
        let
          pkgs = importNixpkgs system;
          pkgsUnstable = importNixpkgsUnstable system;
        in
        {
          default = pkgs.mkShell {
            name = "likvid-cloudfoundation";
            packages = (github_actions_preinstalled pkgs) ++ (core_packages pkgs pkgsUnstable) ++ (developer_packages pkgs);
          };
        };

    in
    {
      devShells = {
        aarch64-darwin = (defaultShellForSystem "aarch64-darwin");
        x86_64-darwin = (defaultShellForSystem "x86_64-darwin");
        x86_64-linux = (defaultShellForSystem "x86_64-linux") // {
          # use a smaller/faster shell on github actions
          github_actions =
            let
              pkgs = importNixpkgs "x86_64-linux";
              pkgsUnstable = importNixpkgsUnstable "x86_64-linux";
            in
            pkgs.mkShell {
              name = "likvid-cloudfoundation-ghactions";
              packages = (core_packages pkgs pkgsUnstable);
            };
        };
      };
    };
}

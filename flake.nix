{
  description = "Terraform development environment with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            terraform
            terraform-ls
            awscli2
            # Optional: Add other tools you might need
            # kubectl
            # docker
          ];

          shellHook = ''
            export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
            mkdir -p "$TF_PLUGIN_CACHE_DIR"
            
            # AWS CLI Configuration
            # Explicitly select which config to use via USE_PROJECT_AWS_CONFIG environment variable
            # Set USE_PROJECT_AWS_CONFIG=1 to use project .aws/ directory
            # Leave unset to use host ~/.aws/ directory (default)
            if [ "$USE_PROJECT_AWS_CONFIG" = "1" ]; then
              if [ -d ".aws" ]; then
                export AWS_CONFIG_FILE="$(pwd)/.aws/config"
                export AWS_SHARED_CREDENTIALS_FILE="$(pwd)/.aws/credentials"
                echo "AWS config: Using project-specific configuration from .aws/"
              else
                echo "⚠️  USE_PROJECT_AWS_CONFIG=1 but .aws/ directory not found"
                echo "AWS config: Falling back to host configuration from ~/.aws/"
              fi
            elif [ -n "$AWS_CONFIG_FILE" ] && [ -n "$AWS_SHARED_CREDENTIALS_FILE" ]; then
              echo "AWS config: Using custom paths from environment variables"
            else
              echo "AWS config: Using host configuration from ~/.aws/"
            fi
            
            echo "🚀 Terraform development environment ready!"
            echo "Terraform version: $(terraform version | head -n 1)"
            echo "TF_PLUGIN_CACHE_DIR: $TF_PLUGIN_CACHE_DIR"
          '';
        };
      }
    );
}

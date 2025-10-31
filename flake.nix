{
  outputs = inputs@{ self, flake-parts, nixos-generators, rebuild, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      flake = {
        nixosModules.base = { config, ... }: {
          imports = [
            ./configurations/base.nix
            (if rebuild.value then
              ./configurations/raspberrypi-rebuild.nix
            else
              nixos-generators.nixosModules.all-formats)
          ];
          nixpkgs.hostPlatform = "aarch64-linux";
        };

        nixosConfigurations.k3s-master = inputs.nixpkgs.lib.nixosSystem {
          modules = [ self.nixosModules.base ./configurations/k3s-master.nix ];
          specialArgs = {
            inherit inputs;
            hostName = "k3s-master";
            address = "192.168.1.170";
          };
        };

        nixosConfigurations.k3s-node01 = inputs.nixpkgs.lib.nixosSystem {
          modules = [ self.nixosModules.base ./configurations/k3s-node.nix ];
          specialArgs = {
            inherit inputs self;
            hostName = "k3s-node01";
            address = "192.168.1.171";
          };
        };

        nixosConfigurations.k3s-node02 = inputs.nixpkgs.lib.nixosSystem {
          modules = [ self.nixosModules.base ./configurations/k3s-node.nix ];
          specialArgs = {
            inherit inputs self;
            hostName = "k3s-node02";
            address = "192.168.1.172";
          };
        };

        nixosConfigurations.k3s-node03 = inputs.nixpkgs.lib.nixosSystem {
          modules = [ self.nixosModules.base ./configurations/k3s-node.nix ];
          specialArgs = {
            inherit inputs self;
            hostName = "k3s-node03";
            address = "192.168.1.173";
          };
        };


      };
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            argocd
            cilium-cli
            inputs.nil.packages.${system}.nil
            kube-capacity
            nixos-rebuild
            talosctl
          ];
        };
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    rebuild.url = "github:boolean-option/true";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}

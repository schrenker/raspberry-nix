{
  outputs = inputs@{ self, flake-parts, nixos-generators, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      flake = {
        nixosModules.generators = { config, ... }: {
          imports = [ nixos-generators.nixosModules.all-formats ];
          nixpkgs.hostPlatform = "aarch64-linux";
        };

        # It seems like building an sd img and rebuilding a live system requires completely different configs, for root filesystems, boot process, etc. I was unable to rebuild a live system with the same configuration as I built img (due to nixosGenerators module) and vice versa. Therefore, create .img with nixosConfigurations ending with _sd suffix, and rebuild already running system without suffix.
        nixosConfigurations.k3s_raspberry_master_sd = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            ./configurations/base.nix
            self.nixosModules.generators
            ./configurations/k3s-master.nix
          ];
          specialArgs = {
            inherit inputs;
            hostName = "k3s-master";
          };
        };

        nixosConfigurations.k3s_raspberry_master = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            ./configurations/base.nix
            ./configurations/raspberrypi-rebuild.nix
            ./configurations/k3s-master.nix
          ];
          specialArgs = {
            inherit inputs;
            hostName = "k3s-master";
          };
        };

      };
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            inputs.nil.packages.${system}.nil
            nixos-rebuild
          ];
        };
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

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

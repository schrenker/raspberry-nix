{ lib, pkgs, specialArgs, ... }:

{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  security.sudo.wheelNeedsPassword = false;
  services.openssh.enable = true;
  services.rpcbind.enable = true;

  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.254" "9.9.9.9" ];
  networking.hostName = specialArgs.hostName;
  networking.firewall.enable = false;

  time.timeZone = "Europe/Warsaw";

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword =
      "$y$j9T$n3O9OwpZhBIdE.EVjrv.z.$aXdFNEAcQOWG3sj9yTm90pUh2bMP5V5wo6uXDDLIhO8";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAG0Q9SO1UHD1lFrUwaZW3S74jHwLuu26WKgUcJqNHNG"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO4JDlM3XMj7UjdJAHPnQnZ7sLEYRpSufz2mBVhQxqV"
    ];
  };

  environment.systemPackages = with pkgs; [ vim ];

  boot.supportedFilesystems = [ "nfs" ];

  system.stateVersion = "23.11";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}

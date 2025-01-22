{ config, ... }:

{
  boot.supportedFilesystems = [ "nfs" ];

  networking.interfaces.end0.ipv4.addresses = [{
    address = "192.168.1.66";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.firewall.allowedTCPPorts = [ 6443 4240 ];
  networking.firewall.allowedUDPPorts = [ 8472 ];

  services.rpcbind.enable = true;

  services.k3s = {
    enable = true;
    role = "agent";
    token = "very-secret-token"; # This is temporary lab environment
    images = [ config.services.k3s.package.airgapImages ];
    serverAddr = "https://192.168.1.65:6443";
  };
}

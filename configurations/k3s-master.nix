{ config, ... }:

{
  boot.supportedFilesystems = [ "nfs" ];

  networking.interfaces.end0.ipv4.addresses = [{
    address = "192.168.1.65";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  services.rpcbind.enable = true;

  services.k3s = {
    enable = true;
    role = "server";
    token = "very-secret-token"; # This is temporary lab environment
    images = [ config.services.k3s.package.airgapImages ];
    extraFlags = [
      "--flannel-backend=none"
      "--disable-kube-proxy"
      "--disable servicelb"
      "--disable-network-policy"
      "--disable traefik"
      "--cluster-init"
      "--cluster-cidr 10.42.0.0/16"
      "--service-cidr 10.43.0.0/16"
      "--node-label type=agent"
    ];
  };
}

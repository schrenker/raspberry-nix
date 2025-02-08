{ specialArgs, config, ... }:

{

  networking.interfaces.end0.ipv4.addresses = [{
    address = specialArgs.address;
    prefixLength = 24;
  }];

  services.k3s = {
    enable = true;
    role = "server";
    token = "very-secret-token";
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
      "--node-taint node-role.kubernetes.io/master:NoSchedule"
    ];
  };
}

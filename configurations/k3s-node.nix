{ self, specialArgs, config, ... }:

{
  networking.interfaces.end0.ipv4.addresses = [{
    address = specialArgs.address;
    prefixLength = 24;
  }];

  services.k3s = {
    enable = true;
    role = "agent";
    token = "very-secret-token";
    images = [ config.services.k3s.package.airgapImages ];
    serverAddr = "https://" + (builtins.elemAt self.nixosConfigurations.k3s-master.config.networking.interfaces.end0.ipv4.addresses 0).address + ":6443";
    extraFlags = [ "--node-label type=agent" ];
  };
}

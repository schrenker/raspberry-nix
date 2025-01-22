{ config, lib, pkgs, specialArgs, ... }:

{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  security.sudo.wheelNeedsPassword = false;
  services.openssh.enable = true;

  networking.hostName = specialArgs.hostName;
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [
      22 # ssh
      6443 # kube-apiserver
      2379 # etcd
      2380 # etcd
      4240 # cilium health checks
      4244 # cilium hubble health check
      4245 # cilium hubble relay
      4250 # cilium mutual auth port
      #4251 # spire agent (?)
      #6060 # cilium agent pprof server
      #6061 # cilium operator pprof server
      #6062 # hubble relay pprof server
      #9878 # cilium envoy health listener
      #9879 # cilium agent health status api
      #9890 # cilium gops server
      #9901 # cilium envoy admin api
      9962 # cilium agent prometheus metrics
      9963 # cilium operator prometheus metrics
      9964 # cilium envoy prometheus metrics
      #10250 # kubelet API (needed in k3s?)
      #10256 # kube-proxy (needed if cilium is used instead of kp?)
      #10257 # kube-controller-manager (needed in k3s?)
      #10259 # kube-scheduler (needed in k3s?)
      { # Node port range
        from = 30000;
        to = 32767;
      }
    ];
    allowedUDPPorts = [ 8472 ];
  };

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

  system.stateVersion = "23.11";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}

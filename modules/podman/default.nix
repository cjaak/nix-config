{ config, pkgs, ... }: {

virtualisation.podman = {
  enable = true;
  dockerCompat = true;
  extraPackages = [ pkgs.zfs ];
  defaultNetwork.settings = {
    dns_enabled = true;
    dns = ["8.8.8.8" "8.8.4.4"];
    };
  };
virtualisation.oci-containers = {
backend = "podman";
};
networking.firewall.interfaces.podman0.allowedUDPPorts = [ 53 ];
}

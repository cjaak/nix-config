{ config, ... }:
{
  networks.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];  # Example ports for SSH, HTTP, HTTPS
    allowedUDPPorts = [ ];           # Add UDP ports if necessary
  };
  # Add other external network configurations here
}
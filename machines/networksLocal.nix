{ config, ... }:
{
  networking = {
    hostName = "nixos-server";  # Your server's hostname
    interfaces.eth0.ip4 = [ { address = "192.168.1.2"; prefixLength = 24; } ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" ];
  };
  # Additional local network settings can be added here
}
{ config, ... }:
{
  networks = {
    lan = {
      enable = true; # Assuming you want to explicitly enable this network definition
      interface = "eth0";
      cidr = "192.168.1.0/24";  # CIDR notation for your LAN

      reservations = [
        {
          hostname = "nixos-server"; # Your server's hostname
          ip-address = "192.168.178.59"; # The desired static IP address for this host
        }
        # ... other reservations if needed
      ];
    };

    # Assuming that defaultGateway and nameservers apply to the LAN
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" ];
  };

  # Additional local network settings can be added here
}
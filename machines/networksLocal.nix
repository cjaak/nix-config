{ config, ... }:
{
  networks = {
    lan = {
      enable = true;
      interface = "eth0";  # Adjust this as per your network interface
      cidr = "192.168.178.0/24";

      reservations = [
        {
          hostname = "nixos-server";
          ip-address = "192.168.178.59";
        }
        {
          hostname = "raspberrypi";
          ip-address = "192.168.178.44";
        }
        # ... other reservations for different hosts
      ];
    };

    defaultGateway = "192.168.178.1";  # Update this to match your gateway
    nameservers = [ "192.168.178.1" ];  # Update this to match your DNS server
  };

  # Additional local network settings can be added here
}
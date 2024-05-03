{ config, vars, ... }:
let
  # Define directories for persistent storage
  directories = [
    "${vars.serviceConfigRoot}/ryot/data"
    ];
in
{
  # Create directories with proper permissions
  systemd.tmpfiles.rules = map (x: "d ${x} 0777 share share - -") directories;

  # Configure firewall to allow traffic on port 8000
  networking.firewall.allowedTCPPorts = [ 8000 ];

  # Container management via Podman
  virtualisation.oci-containers = {
    containers = {
      ryot-db = {
        image = "docker.io/postgres:16-alpine";
        restartPolicy = "unless-stopped";
        volumes = [
          "${vars.serviceConfigRoot}/ryot/data:/var/lib/postgresql/data"
        ];
        environment = {
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_USER = "postgres";
          POSTGRES_DB = "postgres";
        };
      };

      ryot = {
        image = "ghcr.io/ignisda/ryot:latest";
        pullPolicy = "always";
        ports = [
          "8000:8000"
        ];
        environment = {
          DATABASE_URL = "postgres://postgres:postgres@ryot-db:5432/postgres";
          # FRONTEND_INSECURE_COOKIES = "true"; # Uncomment if running on HTTP
        };
      };
    };
  };
  }
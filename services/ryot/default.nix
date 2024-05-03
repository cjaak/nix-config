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

  # Container management via Podman
  virtualisation.oci-containers = {
    containers = {
      ryot-db = {
        image = "docker.io/postgres:16-alpine";
        autoStart = true;
        volumes = [
          "${vars.serviceConfigRoot}/ryot/data:/var/lib/postgresql/data"
        ];
        extraOptions = [
          "--network=container:ryot"
        ];
        environment = {
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_USER = "postgres";
          POSTGRES_DB = "postgres";
        };
      };

      ryot = {
        image = "ghcr.io/ignisda/ryot:latest";
        autoStart = true;
        extraOptions = [
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.ryot.rule=Host(`ryot${vars.domainName}`)"
          "-l=traefik.http.services.paperless.loadbalancer.server.port=8282"
          "-l=homepage.group=Services"
          "-l=homepage.name=Ryot"
          "-l=homepage.icon=ryot.svg"
          "-l=homepage.href=https://ryot${vars.domainName}"
          "-l=homepage.description=Ultimate Tracker"
        ];
        environment = {
          PORT = "8282";
          DATABASE_URL = "postgres://postgres:postgres@ryot-db:5432/postgres";
          # FRONTEND_INSECURE_COOKIES = "true"; # Uncomment if running on HTTP
        };
      };
    };
  };
  }
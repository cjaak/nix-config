{ config, vars, ... }:
let
  directories = [
    "${vars.serviceConfigRoot}/nextcloud"
    "${vars.serviceConfigRoot}/nextcloud/db"
    "${vars.serviceConfigRoot}/nextcloud/config"
    "${vars.mainArray}/Nextcloud"
  ];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0777 share share - -") directories;

  systemd.services = {
    podman-nextcloud = {
      requires = [
        "podman-nextcloud-db.service"
        "podman-nextcloud-redis.service"
      ];
      after = [
        "podman-nextcloud-db.service"
        "podman-nextcloud-redis.service"
      ];
    };
    podman-nextcloud-db = {
      requires = [ "podman-nextcloud-redis.service" ];
      after = [ "podman-nextcloud-redis.service" ];
    };
  };

  virtualisation.oci-containers.containers = {
    nextcloud = {
      image = "nextcloud:apache";
      autoStart = true;
      volumes = [
        "${vars.mainArray}/Nextcloud:/var/www/html/data"
        "${vars.serviceConfigRoot}/nextcloud/config:/var/www/html/config"
      ];
      environment = {
        NEXTCLOUD_TRUSTED_DOMAINS = "files.${vars.domainName}";
        NEXTCLOUD_ADMIN_USER = "admin";
        NEXTCLOUD_ADMIN_PASSWORD = "changeme";
        POSTGRES_HOST = "localhost";
        POSTGRES_DB = "nextcloud";
        POSTGRES_USER = "nextcloud";
        POSTGRES_PASSWORD = "nextcloud";
        REDIS_HOST = "localhost";
        PHP_MEMORY_LIMIT = "1G";
        PHP_UPLOAD_LIMIT = "10G";
        NEXTCLOUD_UPDATE = "1";
        TZ = vars.timeZone;
      };
      extraOptions = [
        "--pull=newer"
        "--network=container:nextcloud-redis"
      ];
    };

    nextcloud-db = {
      image = "postgres:16-alpine";
      autoStart = true;
      volumes = [
        "${vars.serviceConfigRoot}/nextcloud/db:/var/lib/postgresql/data"
      ];
      environment = {
        POSTGRES_DB = "nextcloud";
        POSTGRES_USER = "nextcloud";
        POSTGRES_PASSWORD = "nextcloud";
      };
      extraOptions = [
        "--pull=newer"
        "--network=container:nextcloud-redis"
      ];
    };

    nextcloud-redis = {
      image = "redis:alpine";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=traefik.enable=true"
        "-l=traefik.http.routers.nextcloud.rule=Host(`files.${vars.domainName}`)"
        "-l=traefik.http.services.nextcloud.loadbalancer.server.port=80"
        "-l=homepage.group=Services"
        "-l=homepage.name=Nextcloud"
        "-l=homepage.icon=nextcloud.svg"
        "-l=homepage.href=https://files.${vars.domainName}"
        "-l=homepage.description=File storage"
      ];
    };
  };
}
{ config, vars, ... }:
let
  svcRoot = vars.serviceConfigRoot;
in
{
  systemd.tmpfiles.rules =
    map (x: "d ${x} 0777 share share - -") [
      "${svcRoot}/nextcloud"
      "${svcRoot}/nextcloud/db"
    ] ++
    map (x: "d ${x} 0770 33 33 - -") [
      "${svcRoot}/nextcloud/html"
      "${vars.cacheArray}/Nextcloud"
    ];

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
        "${svcRoot}/nextcloud/html:/var/www/html"
        "${vars.cacheArray}/Nextcloud:/data"
      ];
      environment = {
        NEXTCLOUD_TRUSTED_DOMAINS = "files.${vars.domainName}";
        NEXTCLOUD_ADMIN_USER = "admin";
        NEXTCLOUD_ADMIN_PASSWORD = "changeme";
        NEXTCLOUD_DATA_DIR = "/data";
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
        "${svcRoot}/nextcloud/db:/var/lib/postgresql/data"
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
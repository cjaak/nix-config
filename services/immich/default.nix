{ config, vars, ... }:
let
  directories = [
    "${vars.serviceConfigRoot}/immich"
    "${vars.serviceConfigRoot}/immich/postgresql"
    "${vars.serviceConfigRoot}/immich/postgresql/data"
    "${vars.serviceConfigRoot}/immich/config"
    "${vars.serviceConfigRoot}/immich/machine-learning"
    "${vars.mainArray}/Photos"
    "${vars.mainArray}/Photos/Immich"
  ];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0777 share share - -") directories;
  systemd.services = {
    podman-immich = {
      requires = [
        "podman-immich-redis.service"
        "podman-immich-postgres.service"
      ];
      after = [
        "podman-immich-redis.service"
        "podman-immich-postgres.service"
      ];
    };
    podman-immich-postgres = {
      requires = [ "podman-immich-redis.service" ];
      after = [ "podman-immich-redis.service" ];
    };
  };

  virtualisation.oci-containers.containers = {
    immich = {
      autoStart = true;
      image = "ghcr.io/imagegenius/immich:latest";
      volumes = [
        "${vars.serviceConfigRoot}/immich/config:/config"
        "${vars.mainArray}/Photos/Immich:/photos"
        "${vars.serviceConfigRoot}/immich/machine-learning:/config/machine-learning"
      ];
#      environmentFiles = [ config.age.secrets.ariaImmichDatabase.path ];
      environment = {
        PUID = "994";
        PGID = "993";
        TZ = "Europe/Berlin";
        DB_HOSTNAME = "immich-postgres";
        DB_USERNAME = "immich";
        DB_DATABASE_NAME = "immich";
        REDIS_HOSTNAME = "immich-redis";
        DB_PASSWORD = "immich";
      };
      extraOptions = [
        "--pull=newer"
        "--network=container:immich-redis"
        "--device=/dev/dri:/dev/dri"
      ];
    };

    immich-redis = {
      autoStart = true;
      image = "redis";
      extraOptions = [
        "--pull=newer"
        "-l=traefik.enable=true"
        "-l=traefik.http.routers.immich.rule=Host(`photos.${vars.domainName}`)"
        "-l=traefik.http.routers.immich.service=immich"
        "-l=traefik.http.services.immich.loadbalancer.server.port=8080"
        "-l=homepage.group=Services"
        "-l=homepage.name=Immich"
        "-l=homepage.description=Photo client"
        "-l=homepage.icon=immich.svg"
        "-l=homepage.href=https://photos.${vars.domainName}"
        "-l=homepage.widget.type=immich"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_IMMICH_KEY}}"
        "-l=homepage.widget.url=http://immich-redis:8080"
      ];
    };

    immich-postgres = {
      autoStart = true;
      image = "tensorchord/pgvecto-rs:pg14-v0.2.1";
      volumes = [
        "${vars.serviceConfigRoot}/immich/postgresql/data:/var/lib/postgresql/data"
      ];
#      environmentFiles = [ config.age.secrets.ariaImmichDatabase.path ];
      environment = {
        POSTGRES_PASSWORD = "immich";
        POSTGRES_USER = "immich";
        POSTGRES_DB = "immich";
      };
      extraOptions = [
        "--pull=newer"
        "--network=container:immich-redis"
      ];
    };
  };
}
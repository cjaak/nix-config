{ config, vars, ... }:
let
  directories = [
    "${vars.serviceConfigRoot}/wger/static"
    "${vars.serviceConfigRoot}/wger/media"
    "${vars.serviceConfigRoot}/wger/postgres-data"
    "${vars.serviceConfigRoot}/wger/redis-data"
    "${vars.serviceConfigRoot}/wger/celery-beat"
  ];
in
{
  # Define temporary directories for static data
  systemd.tmpfiles.rules = map (x: "d ${x} 0777 share share - -") directories;

  # Define Podman containers
  virtualisation.oci-containers = {
    containers = {
      web = {
        image = "wger/server:latest";
        autoStart = true;
        dependsOn = ["db" "cache"];
        extraOptions = [
          "--health-cmd=wget --no-verbose --tries=1 --spider http://localhost:8000"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-start-period=300s"
          "--health-retries=5"
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.wger.rule=Host(`wger.${vars.domainName}`)"
          "-l=traefik.http.services.wger.loadbalancer.server.port=8000"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/wger/static:/home/wger/static"
          "${vars.serviceConfigRoot}/wger/media:/home/wger/media"
          "${vars.serviceConfigRoot}/wger/config/prod.env:/etc/environment:ro"
        ];
      };

      nginx = {
        image = "nginx:stable";
        autoStart = true;
        dependsOn = ["web"];
        ports = ["80:80"];
        extraOptions = [
          "--health-cmd='service nginx status'"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=5"
          "--health-start-period=30s"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/wger/config/nginx.conf:/etc/nginx/conf.d/default.conf:ro"
          "${vars.serviceConfigRoot}/wger/static:/wger/static:ro"
          "${vars.serviceConfigRoot}/wger/media:/wger/media:ro"
        ];
      };

      db = {
        image = "postgres:15-alpine";
        autoStart = true;
        environment = {
          POSTGRES_USER = "wger";
          POSTGRES_PASSWORD = "wger";
          POSTGRES_DB = "wger";
        };
        extraOptions = [
          "--health-cmd=pg_isready -U wger"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=5"
          "--health-start-period=30s"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/wger/postgres-data:/var/lib/postgresql/data"
        ];
      };

      cache = {
        image = "redis";
        autoStart = true;
        extraOptions = [
          "--health-cmd='redis-cli ping'"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=5"
          "--health-start-period=30s"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/wger/redis-data:/data"
        ];
      };

      celery_worker = {
        image = "wger/server:latest";
        autoStart = true;
        dependsOn = ["web"];
        extraOptions = [
          "--entrypoint" "/start-worker"
          "--health-cmd='celery -A wger inspect ping'"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=5"
          "--health-start-period=30s"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/wger/media:/home/wger/media"
        ];
      };

      celery_beat = {
        image = "wger/server:latest";
        autoStart = true;
        extraOptions = [
          "--entrypoint" "/start-beat"
        ];
        dependsOn = ["celery_worker"];
        volumes = [
          "${vars.serviceConfigRoot}/wger/celery-beat:/home/wger/beat"
        ];
      };
    };
  };
}

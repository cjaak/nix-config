{ vars, ... }:
let
  svcRoot = vars.serviceConfigRoot;
  dbPassword = "rreading-glasses";
in
{
  systemd.tmpfiles.rules = [
    "d ${svcRoot}/rreading-glasses 0777 share share - -"
    "d ${svcRoot}/rreading-glasses/db 0777 nobody nobody - -"
  ];

  virtualisation.oci-containers.containers = {
    rreading-glasses-db = {
      image = "postgres:17";
      autoStart = true;
      extraOptions = ["--pull=newer"];
      volumes = [
        "${svcRoot}/rreading-glasses/db:/var/lib/postgresql/data"
      ];
      environment = {
        POSTGRES_USER = "rreading-glasses";
        POSTGRES_PASSWORD = dbPassword;
        POSTGRES_DB = "rreading-glasses";
      };
    };

    rreading-glasses = {
      image = "blampe/rreading-glasses:latest";
      autoStart = true;
      dependsOn = ["rreading-glasses-db"];
      extraOptions = [
        "--pull=newer"
        "--memory=128m"
        "--entrypoint=/main"
        "-l=traefik.enable=true"
        "-l=traefik.http.routers.rreading-glasses.rule=Host(`books-meta.${vars.domainName}`)"
        "-l=traefik.http.services.rreading-glasses.loadbalancer.server.port=8788"
      ];
      cmd = ["serve" "--upstream=www.goodreads.com" "--verbose"];
      environment = {
        POSTGRES_HOST = "rreading-glasses-db";
        POSTGRES_DATABASE = "rreading-glasses";
        POSTGRES_USER = "rreading-glasses";
        POSTGRES_PASSWORD = dbPassword;
      };
    };
  };
}
{ config, vars, ... }:
let
  svcRoot = vars.serviceConfigRoot;
in
{
  systemd.tmpfiles.rules = [
    "d ${svcRoot}/filebrowser 0777 share share - -"
    "f ${svcRoot}/filebrowser/filebrowser.db 0666 share share - -"
  ];

  virtualisation.oci-containers.containers = {
    filebrowser = {
      image = "filebrowser/filebrowser:latest";
      autoStart = true;
      cmd = ["--port" "8082"];
      user = "994:993";
      volumes = [
        "${vars.mainArray}/Media:/srv/Media"
        "${svcRoot}/filebrowser/filebrowser.db:/database/filebrowser.db"
      ];
      extraOptions = [
        "--pull=newer"
        "--no-healthcheck"
        "-l=traefik.enable=true"
        "-l=traefik.http.routers.filebrowser.rule=Host(`browse.${vars.domainName}`)"
        "-l=traefik.http.services.filebrowser.loadbalancer.server.port=8082"
        "-l=homepage.group=Services"
        "-l=homepage.name=FileBrowser"
        "-l=homepage.icon=filebrowser.svg"
        "-l=homepage.href=https://browse.${vars.domainName}"
        "-l=homepage.description=File browser"
      ];
    };
  };
}
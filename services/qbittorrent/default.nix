{ config, vars, ... }:
let
directories = [
"${vars.serviceConfigRoot}/radarr"
"${vars.serviceConfigRoot}/prowlarr"
"${vars.serviceConfigRoot}/recyclarr"
"${vars.mainArray}/Media/Downloads"
];
  in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0777 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      qbittorrent = {
        image = "linuxserver/qbittorrent:latest";
        autoStart = true;
        dependsOn = [
          "gluetun"
        ];
        extraOptions = [
        "--network=container:gluetun"
        "-l=homepage.group=Arr"
        "-l=homepage.name=qbittorent"
        "-l=homepage.icon=qbittorrent.svg"
        "-l=homepage.href=https://qbittorrent.${vars.domainName}"
        "-l=homepage.description=Torrent client"
        "-l=homepage.widget.type=qbittorrent"
        "-l=homepage.widget.username=charlie"
        "-l=homepage.widget.password=qbittorrent"
        "-l=homepage.widget.url=http://gluetun:8080"
        ];
        volumes = [
          "${vars.mainArray}/Media/Downloads:/data/completed"
          "${vars.serviceConfigRoot}:/config"
        ];
        environment = {
          WEB_UI_PORT = "8080";
          TZ = vars.timeZone;
          PUID = "994";
          PGID = "993";
        };
      };
      gluetun = {
        image = "qmcgaw/gluetun:latest";
        autoStart = true;
        extraOptions = [
        "--cap-add=NET_ADMIN"
        "-l=traefik.enable=true"
        "-l=traefik.http.routers.qbittorrent.rule=Host(`qbittorrent.${vars.domainName}`)"
        "-l=traefik.http.routers.qbittorrent.service=qbittorrent"
        "-l=traefik.http.services.qbittorrent.loadbalancer.server.port=8080"
        "--device=/dev/net/tun:/dev/net/tun"
        "-l=homepage.group=Arr"
        "-l=homepage.name=Gluetun"
        "-l=homepage.icon=gluetun.svg"
        "-l=homepage.href=https://qbittorrent.${vars.domainName}"
        "-l=homepage.description=VPN killswitch"
        "-l=homepage.widget.type=gluetun"
        "-l=homepage.widget.url=http://gluetun:8000"
        ];
        ports = [
          "127.0.0.1:8083:8000"
        ];
        environmentFiles = [
          config.age.secrets.wireguardCredentials.path
        ];
        environment = {
          VPN_TYPE = "wireguard";
          VPN_SERVICE_PROVIDER =  "custom";
          FIREWALL_DEBUG = "on";
          WIREGUARD_MTU = "1300";
          FIREWALL_VPN_INPUT_PORTS="6881";
        };
      };
    };
};
}

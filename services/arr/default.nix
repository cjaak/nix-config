{ inputs, lib, config, pkgs, vars, ... }:
  let
directories = [
"${vars.serviceConfigRoot}/bazarr"
"${vars.serviceConfigRoot}/sonarr"
"${vars.serviceConfigRoot}/radarr"
"${vars.serviceConfigRoot}/prowlarr"
"${vars.serviceConfigRoot}/recyclarr"
"${vars.serviceConfigRoot}/booksonic"
"${vars.mainArray}/Media/Downloads"
"${vars.mainArray}/Media/TV"
"${vars.mainArray}/Media/Movies"
"${vars.mainArray}/Media/Audiobooks"
"${vars.mainArray}/Media/Books"
];
  in
  {

system.activationScripts.recyclarr_configure = ''
    sed=${pkgs.gnused}/bin/sed
    configFile=${vars.serviceConfigRoot}/recyclarr/recyclarr.yml
    sonarr="${inputs.recyclarr-configs}/sonarr/templates/web-2160p-v4.yml"
    sonarrApiKey=$(cat "${config.age.secrets.sonarrApiKey.path}")
    radarr="${inputs.recyclarr-configs}/radarr/templates/remux-web-2160p.yml"
    radarrApiKey=$(cat "${config.age.secrets.radarrApiKey.path}")

    cat $sonarr > $configFile
    $sed -i"" "s/Put your API key here/$sonarrApiKey/g" $configFile
    $sed -i"" "s/Put your Sonarr URL here/https:\/\/sonarr.${vars.domainName}/g" $configFile

    printf "\n" >> ${vars.serviceConfigRoot}/recyclarr/recyclarr.yml
    cat $radarr >> ${vars.serviceConfigRoot}/recyclarr/recyclarr.yml
    $sed -i"" "s/Put your API key here/$radarrApiKey/g" $configFile
    $sed -i"" "s/Put your Radarr URL here/https:\/\/radarr.${vars.domainName}/g" $configFile

    '';
  
  systemd.tmpfiles.rules = map (x: "d ${x} 0777 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      sonarr = {
        image = "lscr.io/linuxserver/sonarr:develop";
        autoStart = true;
        extraOptions = [
          "--pull=newer"
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.sonarr.rule=Host(`sonarr.${vars.domainName}`)"
          "-l=traefik.http.services.sonarr.loadbalancer.server.port=8989"
          "-l=homepage.group=Arr"
          "-l=homepage.name=Sonarr"
          "-l=homepage.icon=sonarr.svg"
          "-l=homepage.href=https://sonarr.${vars.domainName}"
          "-l=homepage.description=TV show tracker"
          "-l=homepage.widget.type=sonarr"
          "-l=homepage.widget.key={{HOMEPAGE_FILE_SONARR_KEY}}"
          "-l=homepage.widget.url=http://sonarr:8989"
        ];
        volumes = [
            "${vars.mainArray}/Media/Downloads:/downloads"
            "${vars.mainArray}/Media/TV:/tv"
            "${vars.serviceConfigRoot}/sonarr:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          PGID = "993";
          UMASK = "002";
        };
      };
      prowlarr = {
        image = "binhex/arch-prowlarr";
        autoStart = true;
        extraOptions = [
          "--pull=newer"
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.prowlarr.rule=Host(`prowlarr.${vars.domainName}`)"
          "-l=traefik.http.services.prowlarr.loadbalancer.server.port=9696"
          "-l=homepage.group=Arr"
          "-l=homepage.name=Prowlarr"
          "-l=homepage.icon=prowlarr.svg"
          "-l=homepage.href=https://prowlarr.${vars.domainName}"
          "-l=homepage.description=Torrent indexer"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/prowlarr:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          PGID = "993";
          UMASK = "002";
        };
      };
      radarr = {
        image = "lscr.io/linuxserver/radarr";
        autoStart = true;
        extraOptions = [
          "--pull=newer"
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.radarr.rule=Host(`radarr.${vars.domainName}`)"
          "-l=traefik.http.services.radarr.loadbalancer.server.port=7878"
          "-l=homepage.group=Arr"
          "-l=homepage.name=Radarr"
          "-l=homepage.icon=radarr.svg"
          "-l=homepage.href=https://radarr.${vars.domainName}"
          "-l=homepage.description=Movie tracker"
          "-l=homepage.widget.type=radarr"
          "-l=homepage.widget.key={{HOMEPAGE_FILE_RADARR_KEY}}"
          "-l=homepage.widget.url=http://radarr:7878"
        ];
        volumes = [
            "${vars.mainArray}/Media/Downloads:/downloads"
            "${vars.mainArray}/Media/Movies:/movies"
            "${vars.serviceConfigRoot}/radarr:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          PGID = "993";
          UMASK = "002";
        };
      };
      booksonic = {
        image = "lscr.io/linuxserver/booksonic-air";
        autoStart = true;
        extraOptions = [
          "--pull=newer"
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.booksonic.rule=Host(`booksonic.${vars.domainName}`)"
          "-l=traefik.http.services.booksonic.loadbalancer.server.port=4040"
          "-l=homepage.group=Media"
          "-l=homepage.name=Booksonic"
          "-l=homepage.icon=booksonic.png"
          "-l=homepage.href=https://booksonic.${vars.domainName}"
          "-l=homepage.description=Audiobook server"
        ];
        volumes = [
            "${vars.mainArray}/Media/Audiobooks:/audiobooks"
            "${vars.serviceConfigRoot}/booksonic:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          PGID = "993";
          CONTEXT_PATH = "/";
          UMASK = "002";
        };
      };
      readarr = {
        image = "lscr.io/linuxserver/readarr:develop";
        autoStart = true;
        extraOptions = [
          "--pull=newer"
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.readarr.rule=Host(`readarr.${vars.domainName}`)"
          "-l=traefik.http.services.readarr.loadbalancer.server.port=8787"
          "-l=homepage.group=Arr"
          "-l=homepage.name=Readarr"
          "-l=homepage.icon=readarr.png"
          "-l=homepage.href=https://readarr.${vars.domainName}"
          "-l=homepage.description=Book Tracker"
          "-l=homepage.widget.type=readarr"
          "-l=homepage.widget.key={{HOMEPAGE_FILE_READARR_KEY}}"
          "-l=homepage.widget.url=http://readarr:8787"
        ];
        volumes = [
            "${vars.mainArray}/Media/Books:/books"
            "${vars.mainArray}/Media/Downloads:/downloads"
            "${vars.serviceConfigRoot}/booksonic:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          PGID = "993";
          UMASK = "002";
        };
      };
      bazarr = {
        image = "lscr.io/linuxserver/bazarr:latest";
        autoStart = true;
        extraOptions = [
          "--pull=newer"
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.bazarr.rule=Host(`bazarr.${vars.domainName}`)"
          "-l=traefik.http.services.bazarr.loadbalancer.server.port=6767"
          "-l=homepage.group=Arr"
          "-l=homepage.name=Bazarr"
          "-l=homepage.icon=bazarr.png"
          "-l=homepage.href=https://bazarr.${vars.domainName}"
          "-l=homepage.description=Subtitle Tracker"
          "-l=homepage.widget.type=bazarr"
          "-l=homepage.widget.key={{HOMEPAGE_FILE_BAZARR_KEY}}"
          "-l=homepage.widget.url=http://bazarr:6767"
        ];
        volumes = [
            "${vars.mainArray}/Media/Movies:/movies"
            "${vars.mainArray}/Media/TV:/tv"
            "${vars.serviceConfigRoot}/bazarr:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          PGID = "993";
          UMASK = "002";
        };
      };
      recyclarr = {
        image = "ghcr.io/recyclarr/recyclarr";
        user = "994:993";
        autoStart = true;
        volumes = [
          "${vars.serviceConfigRoot}/recyclarr:/config"
        ];
        environment = {
          CRON_SCHEDULE = "@daily";
        };
      };
    };
  };
}

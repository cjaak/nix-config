{ config, vars, ... }:
let
  # Directories for Minecraft server data
  directories = [
    "${vars.serviceConfigRoot}/minecraft"
  ];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0777 share share - -") directories;

  virtualisation.oci-containers = {
    containers = {
      minecraft = {
        image = "openjdk:17-jdk-slim"; # Using a basic OpenJDK image as the base
        autoStart = true;
        extraOptions = [
          "-p 25565:25565" # Minecraft default port mapping
        ];
        volumes = [
          "${vars.serviceConfigRoot}/minecraft:/data" # Mount the Minecraft data directory
        ];
        environment = {
          # Environment variables for JVM and Minecraft server (customize as needed)
          JVM_OPTS = "-Xms1G -Xmx10G";
          EULA = "true"; # Confirm EULA agreement; set appropriately
        };
        command = [
          "java"
          "$JVM_OPTS"
          "-jar /data/server.jar"
          "nogui"
        ];
      };
    };
  };

}
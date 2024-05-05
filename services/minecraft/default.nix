{ config, vars, ... }:
let
  # Directories for Minecraft server data
  directories = [
    "${vars.serviceConfigRoot}/minecraft"
  ];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0777 minecraft minecraft - -") directories;

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

  # Ensure proper permissions and ownership of the Minecraft server directory
  services.oci-containers.rootless = {
    enable = true;
    users = {
      minecraft = {
        subuidStart = 100000;
        subuidCount = 65536;
        subgidStart = 100000;
        subgidCount = 65536;
      };
    };
  };
}
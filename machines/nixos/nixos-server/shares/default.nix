{ users, pkgs, config, lib, ...}:
let

  smb = {
    share_list = {
      Backups = { path = "/mnt/user/Backups"; };
      Documents = { path = "/mnt/cache/Documents"; };
      Media = { path = "/mnt/user/Media"; };
      Photos = { path = "/mnt/user/Photos"; };
      Misc = { path = "/mnt/user/Misc";  };
      TimeMachine = { path = "/mnt/cache/TimeMachine"; "fruit:time machine" = "yes"; };
      YoutubeArchive = { path = "/mnt/user/YoutubeArchive"; };
      YoutubeCurrent = { path = "/mnt/cache/YoutubeCurrent"; };
    };
    share_params = {
      "browseable" = "yes";
      "writeable" = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "valid users" = "share"; 
      "fruit:aapl" = "yes";
      "vfs objects" = "catia fruit streams_xattr";
    };
  };
  smb_shares = builtins.mapAttrs (name: value: value // smb.share_params) smb.share_list;
in
{
services.samba-wsdd.enable = true; # make shares visible for windows 10 clients

users = {
groups.share = {
  gid = 993;
};
users.share = {
  uid = 994;
  isSystemUser = true;
  group = "share";
};
};

environment.systemPackages = [ config.services.samba.package ];

users.users.charlie.extraGroups = ["share"];

systemd.tmpfiles.rules = map (x: "d ${x.path} 0777 share share - -") (lib.attrValues smb.share_list) ++ ["d /mnt 0775 share share - -"];

system.activationScripts.samba_user_create = ''
    smb_password=$(cat "${config.age.secrets.sambaPassword.path}")
    echo -e "$smb_password\n$smb_password\n" | /run/current-system/sw/bin/smbpasswd -a -s share
    '';

networking.firewall = {
  allowedTCPPorts = [ 5357 ];
  allowedUDPPorts = [ 3702 ];
};

services.samba = {
  enable = true;
  openFirewall = true;
  settings = {
        global = lib.mkMerge [
          {
            workgroup = lib.mkDefault "WORKGROUP";
            "server string" = lib.mkDefault config.networking.hostName;
            "netbios name" = lib.mkDefault config.networking.hostName;
            "security" = lib.mkDefault "user";
            "invalid users" = [ "root" ];
            "hosts allow" = lib.mkDefault (lib.strings.concatStringsSep " " smb_networks);
            "guest account" = lib.mkDefault "nobody";
            "map to guest" = lib.mkDefault "bad user";
            "passdb backend" = lib.mkDefault "tdbsam";
          }
          cfg.globalSettings
        ];
      }// builtins.mapAttrs (name: value: value // cfg.commonSettings) cfg.shares;
};
services.avahi = {
  enable = true;
  nssmdns4 = true;
  publish = {
    enable = true;
    addresses = true;
    domain = true;
    hinfo = true;
    userServices = true;
    workstation = true;
  };
  extraServiceFiles = {
    smb = ''
      <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
      <name replace-wildcards="yes">%h</name>
      <service>
      <type>_smb._tcp</type>
      <port>445</port>
      </service>
      </service-group>
      '';
 };
};
}

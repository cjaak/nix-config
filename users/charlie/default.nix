{ config, pkgs, lib, ... }: 
{
  nix.settings.trusted-users = [ "charlie" ];

  age.identityPaths = ["/home/charlie/.ssh/id_ed25519"];

  age.secrets.hashedUserPassword = {
    file = ../../secrets/hashedUserPassword.age;
  };

  email = {
    fromAddress = "server@charlie-hub.cloud";
    toAddress = "chwiegand@proton.me";
    smtpServer = "smtp.ionos.de";
    smtpUsername = "server@charlie-hub.cloud";
    smtpPasswordPath = config.age.secrets.smtpPassword.path;
  };


  users = {
    users = {
      charlie = {
        shell = pkgs.zsh;
        uid = 1000;
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets.hashedUserPassword.path;
        extraGroups = [ "wheel" "users" "video" "podman" ];
        group = "charlie";
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBwCrkUq76rnolIfL8eApseG7rlmxCWDlqPx2Xti/fYH chwiegand@proton.me" ];
      };
    };
    groups = {
      charlie = {
        gid= 1000;
      };
    };
  };

  programs.zsh.enable = true;

}

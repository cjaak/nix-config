{ inputs, lib, config, pkgs,  ... }: 
let
  home = {
    username = "charlie";
    homeDirectory = "/home/charlie";
    stateVersion = "23.11";
    };
in
{
  nixpkgs = {
    overlays = [
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  home = home;

  imports = [
      ../../dots/zsh/default.nix
      ../../dots/nvim/default.nix
      ../../dots/neofetch/default.nix
      ../../dots/kitty/default.nix
      ./packages.nix
  ];

  programs.nix-index =
  {
    enable = true;
    enableZshIntegration = true;
  };


  programs.git = {
    enable = true;
    userName  = "charlie";
    userEmail = "chwiegand@proton.me";
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
  }

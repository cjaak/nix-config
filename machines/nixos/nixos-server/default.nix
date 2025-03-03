{ inputs, lib, config, vars, pkgs, ... }:
{
  boot.kernelModules = [ "i915" ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  boot.zfs.forceImportRoot = true;
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [  "nvme-Fanxiang_S500Pro_256GB_FXS500Pro234940404" ];
      immutable = false;
      availableKernelModules = [  "uhci_hcd" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
      removableEfi = true;
      kernelParams = [ 
      "pcie_aspm=force"
      "consoleblank=60"
      "amd_pstate=active"
      ];
      sshUnlock = {
        enable = false;
        authorizedKeys = [ ];
      };
    };
    networking = {
      hostName = "nixos-server";
      timeZone = "Europe/Berlin";
      hostId = "0730ae51";
    };
  };

  imports = [
    ./filesystems
    ./shares ];

  powerManagement.powertop.enable = true;

  systemd.services.hd-idle = {
    description = "HD spin down daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 900";
    };
  };

  networking = {
  useDHCP = true;
  networkmanager.enable = false;
  firewall = {
    allowPing = true;
    allowedTCPPorts = [ 5201 ];
  };
  nameservers = [ "192.168.178.1" ];  # Updated DNS server
  defaultGateway = "192.168.178.1";  # Confirm if this is correct
  interfaces = {
    enp1s0f0.ipv4 = {
      addresses = [{
        address = "192.168.178.59";
        prefixLength = 24;
      }];
      routes = [{
        address = "192.168.178.0";
        prefixLength = 24;
        via = "192.168.178.1";
      }];
    };
  };
};

  virtualisation.docker.storageDriver = "overlay2";

  system.autoUpgrade.enable = true; 

  mover = {
    cacheArray = vars.cacheArray;
    backingArray = vars.slowArray;
    percentageFree = 60;
    excludedPaths = [
      "YoutubeCurrent"
      "Media/Kiwix"
      "Documents"
      "TimeMachine"
      ".DS_Store"
    ];
  };

  environment.systemPackages = with pkgs; [
    pciutils
#    glances
    hdparm
    hd-idle
    hddtemp
    smartmontools
    go
    gotools
    gopls
    go-outline
    gopls
    gopkgs
    gocode-gomod
    godef
    golint
    powertop
    cpufrequtils
    gnumake
    gcc
    intel-gpu-tools
  ];
  }

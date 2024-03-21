{
    description = "my nix home server";
    
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
        nixvim.url = "github:pta2002/nixvim/nixos-23.11";
        home-manager = {
        url = "github:nix-community/home-manager/release-23.11";
        inputs.nixpkgs.follows = "nixpkgs";
        };
        agenix = {
        url = "github:ryantm/agenix";
        inputs.nixpkgs.follows = "nixpkgs";
        };
        recyclarr-configs = {
        url = "github:recyclarr/config-templates";
        flake = false;
        };
      

        nix-index-database = {
        url = "github:Mic92/nix-index-database";
        inputs.nixpkgs.follows = "nixpkgs";
        };


        nur.url = "github:nix-community/nur";

        deploy-rs.url = "github:serokell/deploy-rs";
    };

    outputs = { self, 
              nixpkgs, 
              home-manager, 
              recyclarr-configs, 
              nixvim, 
              nix-index-database, 
              agenix, 
              deploy-rs,
              nur,
              ... }@inputs:
        let
            networksExternal = import ./machines/networksExternal.nix;
            networksLocal = import ./machines/networksLocal.nix;
        in {     
        
        deploy.nodes = {
            nixos-server = {
                hostname = (self.lib.lists.findSingle (x: x.hostname == "nixos-server") "none" "multiple" networksLocal.networks.lan.reservations);
                profiles.system = {
                sshUser = "charlie";
                user = "root";
                sshOpts = [ "-p" "22" ];
                remoteBuild = true;
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nixos-server;
                };
            };
        };

        nixosConfigurations = {
            "nixos-server" = let
              pkgs = import nixpkgs {
                inherit system;
                config = {
                  permittedInsecurePackages = [ "nix-2.15.3" ];
                  # any other nixpkgs-specific configuration...
                };
              };
            in pkgs.lib.nixosSystem {
                inherit system;
                system = "x86_64-linux";
                specialArgs = {
                    inherit inputs networksLocal networksExternal;
                    vars = import ./machines/nixos/vars.nix;
                };
                nixpkgs.config = {
                    permittedInsecurePackages = [ "nix-2.15.3" ];
                };
                modules = [
                    # Base configuration and modules
                    ./modules/aspm-tuning
                    #./modules/hddtemp-monitor
                    ./modules/zfs-root
                    ./modules/email
                    # ./modules/tg-notify
                    ./modules/podman
                    ./modules/mover
#                    ./modules/motd
                    # ./modules/appdata-backup

                    # # Import the machine config + secrets
                    ./machines/nixos
                    ./machines/nixos/nixos-server
                    ./secrets
                    agenix.nixosModules.default

                    # # Services and applications
                    # ./services/invoiceninja
                    # ./services/paperless-ngx
                    # ./services/icloud-drive
                    # ./services/traefik
                    # ./services/deluge
                    # ./services/arr
                    # ./services/jellyfin
                    # ./services/vaultwarden
                    # ./services/monitoring
                    # ./services/kiwix
                    # ./services/pingvin-share
                    # #./services/scrutiny
                    # ./services/homepage

                    # # User-specific configurations
                    ./users/charlie
                    home-manager.nixosModules.home-manager
                    {
                    home-manager.useGlobalPkgs = false; 
                        home-manager.extraSpecialArgs = { inherit inputs networksLocal networksExternal; };
                        home-manager.users.charlie.imports = [ 
                        agenix.homeManagerModules.default
                        nix-index-database.hmModules.nix-index
                        ./users/charlie/dots.nix 
                        ];
                    home-manager.backupFileExtension = "bak";
                    }
                ];
            };
        };
    };
}
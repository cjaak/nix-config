{ inputs, pkgs, lib, config, ... }: {
  home.packages = with pkgs; [
    grc
  ];

#  age.secrets.bwSessionFish = {
#    file = ../../secrets/bwSessionFish.age;
#  };

  programs.zsh = {
    enable = true;
    zplug = {
      enable = true;
      plugins = [
      { name = "zsh-users/zsh-autosuggestions"; }
      { name = "zsh-users/zsh-syntax-highlighting"; }
      { name = "zsh-users/zsh-completions"; }
      { name = "zsh-users/zsh-history-substring-search"; }
      { name = "unixorn/warhol.plugin.zsh"; }
      { name = "notthebee/prompt"; tags = [ as:theme ]; }
    ];
    };


  };
  }

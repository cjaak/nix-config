{ inputs, pkgs, lib, config, ... }: {
  home.packages = with pkgs; [
    grc
  ];

  age.secrets.bwSessionFish = {
    file = ../../secrets/bwSessionFish.age;
  };

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
    shellAliases = {
      la = "ls --color -lha";
      df = "df -h";
      du = "du -ch";
      ipp = "curl ipinfo.io/ip";
      yh = "yt-dlp --continue --no-check-certificate --format=bestvideo+bestaudio --exec='ffmpeg -i {} -c:a copy -c:v copy {}.mkv && rm {}'";
      yd = "yt-dlp --continue --no-check-certificate --format=bestvideo+bestaudio --exec='ffmpeg -i {} -c:v prores_ks -profile:v 1 -vf fps=25/1 -pix_fmt yuv422p -c:a pcm_s16le {}.mov && rm {}'";
      ya = "yt-dlp --continue --no-check-certificate --format=bestaudio -x --audio-format wav";
      aspm = "sudo lspci -vv | awk '/ASPM/{print $0}' RS= | grep --color -P '(^[a-z0-9:.]+|ASPM )'";
      mkdir = "mkdir -p";
      };

  };
  }

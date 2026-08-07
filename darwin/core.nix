{ pkgs, ... }: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
  system.primaryUser = "ryan";

  nix = {
    settings = {
      trusted-users = [ "root" "ryan" ];
      auto-optimise-store = true;
      max-jobs = "auto";
      extra-experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://pi.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "pi.cachix.org-1:lGeoGJaZ5ZDabuRzkcD5EBTNnDM4HJ1vqeOxlWk1Flk="
      ];
    };
  };

  programs.fish.enable = true;
  programs.tmux.enable = true;
  programs.pi.coding-agent = {
    enable = true;
    settings.npmCommand = [ "${pkgs.nodejs_22}/bin/npm" ];
  };

  environment.shells = [
    pkgs.fish
    pkgs.nushell
    pkgs.zsh
  ];

  environment.systemPackages = [
    pkgs.fish
    pkgs.nushell
    pkgs.starship
    pkgs.tmux
    pkgs.zellij
    pkgs.smug
    pkgs.screen

    pkgs.eza
    pkgs.fd
    pkgs.fzf
    pkgs.ripgrep
    pkgs.bat
    pkgs.bat-extras.batdiff
    pkgs.bat-extras.batman
    pkgs.bat-extras.batgrep
    pkgs.bat-extras.batwatch
    pkgs.lsd
    pkgs.yazi
    pkgs.zoxide
    pkgs.sd
    pkgs.tree
    pkgs.stow

    pkgs.git
    pkgs.delta
    pkgs.git-cliff
    pkgs.lazygit
    pkgs.gitleaks
    pkgs.tig
    pkgs.lefthook
    pkgs.cocogitto
    pkgs.gh-dash

    pkgs.htop
    pkgs.jq
    pkgs.yq-go
    pkgs.frogmouth
    pkgs.glow
    pkgs.nap
    pkgs.nb
    pkgs.taskwarrior3
    pkgs.taskwarrior-tui
    pkgs.vit
    pkgs.tldr
    pkgs.w3m
    pkgs.rich-cli
    pkgs.chafa
    pkgs.viu
    pkgs.ueberzugpp

    pkgs.ack
    pkgs.cloc
    pkgs.tokei
    pkgs.d2
    pkgs.graphviz
    pkgs.gnuplot
    pkgs.pandoc
    pkgs.mdbook
    pkgs.hugo
    pkgs.zola
    pkgs.zk
    pkgs.marp-cli

    pkgs.curl
    pkgs.wget
    pkgs.nmap
    pkgs.sq
    pkgs.caddy
    pkgs.ttyd
    pkgs.gnupg
    pkgs.pinentry-curses

    pkgs.ffmpeg
    pkgs.imagemagick
    pkgs.yt-dlp
    pkgs.vhs
    pkgs.agg
    pkgs.asciinema
    pkgs.whisper-cpp

    pkgs.zathura
    pkgs.ghostscript

    pkgs.mise
    pkgs.just
    pkgs.watchexec
    pkgs.scriptisto
    pkgs.gh
    pkgs.carapace
    pkgs.pngpaste
    pkgs.direnv
    pkgs.zig

    pkgs.docker
    pkgs.docker-compose
    pkgs.docker-credential-helpers
    pkgs.colima
    pkgs.lima
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.k9s
    pkgs.k3d
    pkgs.kubeconform
    pkgs.skaffold
    pkgs.lazydocker

    pkgs.pnpm
    pkgs.deno

    pkgs.hadolint
    pkgs.llama-cpp
    pkgs.opencode
    pkgs.promptfoo
    pkgs.taplo
    pkgs.yamlfmt
    pkgs.herdr

    pkgs.cargo-llvm-cov
    pkgs.gitui
    pkgs.bacon
    pkgs.cargo-nextest
    pkgs.cargo-watch
    pkgs.dprint
    pkgs.presenterm
    pkgs.mprocs
    pkgs.wiki-tui
    pkgs.mdcat
    pkgs.sccache
    pkgs.cargo-audit
    pkgs.cargo-deny
    pkgs.trunk
    pkgs.leptosfmt
    pkgs.dioxus-cli
    pkgs.cargo-edit
    pkgs.cargo-update
    pkgs.cargo-crev

    pkgs.inkscape
    pkgs.devenv
  ];

  fonts.packages = [
    pkgs.nerd-fonts.fantasque-sans-mono
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.symbols-only
    pkgs.nerd-fonts.victor-mono
  ];

  documentation = {
    enable = false;
    man.enable = true;
  };

  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 4; };
    options = "--delete-older-than 14d";
  };

  homebrew = {
    enable = true;
    brews = [
      "aoe"
    ];
    casks = [
      "ghostty"
      "amethyst"
      "hiddenbar"
      "basictex"
      "obs"
    ];
    onActivation.cleanup = "zap";
  };

  launchd.daemons.nix-auto-update = {
    script = ''
      export PATH=/nix/var/nix/profiles/default/bin:${pkgs.nix}/bin:$PATH
      cd /Users/ryan/dotfiles
      echo "=== nix flake update $(date) ==="
      nix --extra-experimental-features "nix-command flakes" flake update 2>&1
      echo "=== darwin-rebuild switch $(date) ==="
      /run/current-system/sw/bin/darwin-rebuild switch --flake /Users/ryan/dotfiles 2>&1
      echo "=== done $(date) ==="
    '';
    serviceConfig = {
      StartCalendarInterval = { Hour = 3; Minute = 0; };
      StandardOutPath = "/var/log/nix-auto-update.log";
      StandardErrorPath = "/var/log/nix-auto-update.log";
    };
  };

  system.stateVersion = 7;
}

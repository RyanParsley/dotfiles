{ pkgs, ... }:
let
  mise-bin = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "mise-bin";
    version = "2026.8.12";

    src = pkgs.fetchurl {
      url = "https://github.com/jdx/mise/releases/download/v${finalAttrs.version}/mise-v${finalAttrs.version}-macos-arm64.tar.xz";
      hash = "sha256-0nXDCuK0J/JUT4wgRmqwKhsKfmvVA6tM3K5RVUpGUh0=";
    };

    sourceRoot = "mise";
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      cp -R . "$out"
      mkdir -p \
        "$out/lib/mise" \
        "$out/share/bash-completion/completions" \
        "$out/share/fish/vendor_completions.d" \
        "$out/share/zsh/site-functions"
      touch "$out/lib/mise/.disable-self-update"

      HOME="$TMPDIR" "$out/bin/mise" completion bash > "$out/share/bash-completion/completions/mise"
      HOME="$TMPDIR" "$out/bin/mise" completion fish > "$out/share/fish/vendor_completions.d/mise.fish"
      HOME="$TMPDIR" "$out/bin/mise" completion zsh > "$out/share/zsh/site-functions/_mise"

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      HOME="$TMPDIR" MISE_OFFLINE=1 "$out/bin/mise" --version | grep -F "${finalAttrs.version}"
    '';

    meta = {
      description = "Front-end to your dev env, using the official release binary";
      homepage = "https://mise.jdx.dev";
      license = pkgs.lib.licenses.mit;
      mainProgram = "mise";
      platforms = [ "aarch64-darwin" ];
      sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
    };
  });
in
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
  # Remove once nixpkgs-unstable includes NixOS/nixpkgs#555604.
  nixpkgs.overlays = [
    (_final: prev: {
      tmux = prev.tmux.overrideAttrs (oldAttrs: {
        buildInputs = oldAttrs.buildInputs ++ [ prev.jemalloc ];
        configureFlags = oldAttrs.configureFlags ++ [ "--enable-jemalloc" ];
      });
      # Remove once Zellij includes zellij-org/zellij#5526 in a release.
      zellij-unwrapped = prev.zellij-unwrapped.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [
          (prev.fetchurl {
            url = "https://github.com/zellij-org/zellij/commit/016f3437979b3e6020b24ae62f2a33e909491c0a.patch";
            hash = "sha256-44BSW0DuU+XC1lWU8hqChQj1MO2x7f6QOsB3Dy/byUk=";
          })
        ];
      });
      curl-impersonate = prev.curl-impersonate.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs
          ++ prev.lib.optional prev.stdenv.hostPlatform.isDarwin prev.fixDarwinDylibNames;
      });
    })
  ];
  system.primaryUser = "ryan";
  environment.variables.PKG_CONFIG_PATH = "${pkgs.imagemagick.dev}/lib/pkgconfig";

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
    pkgs.pkg-config
    pkgs.yt-dlp
    pkgs.vhs
    pkgs.agg
    pkgs.asciinema
    pkgs.whisper-cpp

    pkgs.zathura
    pkgs.ghostscript

    mise-bin
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
    pkgs.tuicr

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
      {
        name = "tmux";
        link = false;
      }
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

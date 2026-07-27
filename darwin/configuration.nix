{ pkgs, ... }: {
  # Apple Silicon
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Required for options that apply to the primary user (e.g. homebrew)
  system.primaryUser = "ryan";

  environment.systemPackages = with pkgs; [

    # ── Terminal / Shell ──────────────────────────────────────────────────────
    fish
    nushell
    starship
    tmux
    zellij
    smug
    screen

    # ── File / Navigation ─────────────────────────────────────────────────────
    eza
    fd
    fzf
    ripgrep
    bat
    bat-extras.batdiff
    bat-extras.batman
    bat-extras.batgrep
    bat-extras.batwatch
    lsd
    yazi
    zoxide
    sd
    tree
    stow

    # ── Git ───────────────────────────────────────────────────────────────────
    git
    delta
    git-cliff
    lazygit
    gitleaks
    tig
    lefthook
    cocogitto

    # ── Productivity / TUI ────────────────────────────────────────────────────
    htop
    jq
    yq-go
    frogmouth
    glow
    nap
    nb
    taskwarrior3
    taskwarrior-tui
    vit
    tldr
    w3m
    rich-cli
    chafa
    viu
    ueberzugpp

    # ── Docs / Diagramming ────────────────────────────────────────────────────
    ack
    cloc
    tokei
    d2
    graphviz
    gnuplot
    pandoc
    mdbook
    hugo
    zola
    zk
    marp-cli

    # ── Network / Security ────────────────────────────────────────────────────
    curl
    wget
    nmap
    sq
    caddy
    ttyd

    # ── Media ─────────────────────────────────────────────────────────────────
    ffmpeg
    imagemagick
    yt-dlp
    vhs
    agg
    asciinema

    # ── PDF / Viewer ──────────────────────────────────────────────────────────
    zathura  # wrapper already bundles pdf-poppler and ps plugins
    ghostscript

    # ── Dev: cross-project tools ──────────────────────────────────────────────
    mise
    just
    watchexec
    scriptisto
    gh
    carapace
    pngpaste

    # ── Dev: containers / kubernetes ──────────────────────────────────────────
    docker
    docker-compose
    docker-credential-helpers
    colima
    lima
    kubectl
    kubernetes-helm
    k9s
    k3d
    kubeconform
    skaffold

    # ── Dev: infra / cloud ────────────────────────────────────────────────────
    azure-cli
    google-cloud-sdk

    # ── Dev: JS / TS ──────────────────────────────────────────────────────────
    pnpm
    deno

    # ── Dev: linters / AI ─────────────────────────────────────────────────────
    hadolint
    llama-cpp
    opencode
    promptfoo

  ];

  # ── Fonts ──────────────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    nerd-fonts.victor-mono
  ];

  # ── Homebrew: residual (not in nixpkgs or macOS-only) ─────────────────────
  homebrew = {
    enable = true;
    brews = [
      "aoe"
      "zentime"
    ];
    casks = [
      "amethyst"
      "hiddenbar"
      "openlens"
      "basictex"
      "copilot-cli"
      "obs"
    ];
    onActivation.cleanup = "zap";
  };

  system.stateVersion = 7;
}

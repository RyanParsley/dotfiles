{ pkgs, ... }: {
  # Apple Silicon
  nixpkgs.hostPlatform = "aarch64-darwin";
  # Required for options that apply to the primary user (e.g. homebrew)
  system.primaryUser = "ryan";

  # Allow ryan to use restricted nix settings (needed for devenv)
  nix.settings.trusted-users = [ "root" "ryan" ];

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
    forgejo-cli

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
    restic

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
    gnupg
    pinentry
    cloudflared

    # ── Media ─────────────────────────────────────────────────────────────────
    ffmpeg
    imagemagick
    yt-dlp
    vhs
    agg
    asciinema
    whisper-cpp

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
    direnv
    zig

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
    lazydocker

    # ── Dev: infra / cloud ────────────────────────────────────────────────────
    azure-cli
    google-cloud-sdk
    cloudflare-wrangler

    # ── Dev: JS / TS ──────────────────────────────────────────────────────────
    pnpm
    deno

    # ── Dev: linters / formatters / AI ────────────────────────────────────────
    hadolint
    llama-cpp
    opencode
    promptfoo
    taplo
    yamlfmt
    woodpecker-cli

    # ── Dev: Rust tooling ─────────────────────────────────────────────────────
    cargo-llvm-cov
    gitui
    bacon
    cargo-nextest
    cargo-watch
    dprint
    presenterm
    mprocs
    wiki-tui
    mdcat
    sccache
    cargo-audit
    cargo-deny
    trunk
    leptosfmt
    dioxus-cli
    cargo-edit
    cargo-update
    cargo-crev

    # ── GUI apps ──────────────────────────────────────────────────────────────
    inkscape
    devenv

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
    taps = [];
    brews = [
      "aoe"
    ];
    casks = [
      "ghostty"
      "amethyst"
      "hiddenbar"
      "openlens"
      "basictex"
      "copilot-cli"
      "obs"
      "espanso"
      "localsend"
    ];
    onActivation.cleanup = "zap";
  };

  system.stateVersion = 7;
}

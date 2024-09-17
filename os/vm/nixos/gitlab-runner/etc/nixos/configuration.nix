{ config, pkgs, lib, ... }:

let
  # General OS settings
  hostname = "gitlab-runner-nix";
  timezone = "Europe/Berlin";
  locale = "en_US.UTF-8";
  keyboard_layout = "de-latin1-nodeadkeys";
  tty_console_font = "ter-132n.psf.gz";

  # GitLab Runner settings
  gitlab_runner_image = "gitlab/gitlab-runner:ubuntu-v17.3.1";
  gitlab_runner_config_dir = "/home/config/gitlab-runner";

  # System profile packages
  system_packages = with pkgs; [
    vim
    wget
    curl
    rsync
    bash-completion
    most
    ncdu
    file
    nettools
    bottom
    htop
  ];
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # VM works with GRUB just fine
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.loader.timeout = 1;

  # Networking configuration: IPv4 only, allo port 22
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  boot.kernelParams = [ "ipv6.disable=1" ];
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Timezone
  time.timeZone = timezone;

  # Locales
  i18n.defaultLocale = locale;
  i18n.extraLocaleSettings = {
    LANGUAGE = locale;
    LC_ALL = locale;
    LC_ADDRESS = locale;
    LC_NAME = locale;
    LC_MONETARY = locale;
    LC_PAPER = locale;
    LC_IDENTIFICATION = locale;
    LC_TELEPHONE = locale;
    LC_MEASUREMENT = locale;
    LC_TIME = locale;
    LC_NUMERIC = locale;
    LANG = locale;
  };

  # Console & Keyboard setup
  console = {
    keyMap = lib.mkDefault keyboard_layout;

    # big font please
    packages = with pkgs; [
      terminus_font
    ];
    font = "${pkgs.terminus_font}/share/consolefonts/${tty_console_font}";

    # don't know what it does but it works this way
    useXkbConfig = false;

    # don't know what it does but it works this way
    earlySetup = true;
  };

  # Modern Nix, please
  nix.settings.experimental-features = "nix-command flakes";

  # Config user setup: network, sudo, docker
  users.users.config = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    openssh.authorizedKeys.keyFiles = [
      ./authorized_keys
    ];
  };

  # Handy shortcuts
  programs.bash.shellAliases = {
    reconfigure-nix = "sudo nixos-rebuild switch --flake /etc/nixos/#default";
    cleanup-nix = "sudo nix-collect-garbage -d && sudo nixos-rebuild boot --flake /etc/nixos/#default && sudo fstrim -v /";
  };

  # Basic packages
  environment.systemPackages = system_packages;

  # Custom CA certificates
  security.pki.certificateFiles = [
    ./ca-root.crt
    ./ca-intermediate.crt
  ];

  # VM services setup
  services.qemuGuest.enable = true;
  services.fstrim.enable = true;
  systemd.services.fstrim.startAt = "daily";

  # OpenSSH setup
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  # Docker setup
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = false;
  virtualisation.docker.daemon.settings = {
    userland-proxy = false;
    experimental = false;
    ipv6 = false;
  };

  # Define GitLab Runner container as systemd service
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      gitlab-runner = {
        image = gitlab_runner_image;
        autoStart = true;
        volumes = [
          # Docker executor needs Docker socket
          "/var/run/docker.sock:/var/run/docker.sock"

          # GitLab Runner config
          "${gitlab_runner_config_dir}:/etc/gitlab-runner"

          # CA certificates
          "/etc/static/ssl/certs/ca-certificates.crt:/etc/gitlab-runner/certs/ca.crt:ro"

          # Do not create a unnamed volumes for the following directories
          "/tmp/gitlab-runner-home:/home/gitlab-runner:ro"
        ];
      };
    };
  };

  # Define a service to cleanup unused images
  systemd.services.docker-gitlab-runner-cleanup = {
    script = ''
      set -eu
      ${pkgs.docker}/bin/docker image prune -af
    '';
    wantedBy = [ "docker.service" ];
    after = [ "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  # ... and run it daily
  systemd.timers.docker-gitlab-runner-cleanup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "docker-gitlab-runner-cleanup.service";
    };
  };


  # ---------------------------------------------------------------
  # --------------- NEVER CHANGE THIS WHEN DEPLOYED ---------------
  # ---------------------------------------------------------------
  system.copySystemConfiguration = false;
  system.stateVersion = "24.05";
}

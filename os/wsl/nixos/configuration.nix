#
# Execute the following at first setup:
#  sudo mkdir -p /opt
#  sudo ln -sf /mnt/c/<path/to/vscode/bin directory> /opt/vscode-bin
#  sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz home-manager
#  sudo nix-channel --add https://github.com/Mic92/nix-ld/archive/main.tar.gz nix-ld
#  sudo nixos-rebuild switch
#
# Then exit out of any WSL shell and restart WSL via PowerShell:
#  wsl --shutdown
#
# Now VS Code + Remote WSL extension should work without any hickups.
#

{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  nixos-wsl = import ./nixos-wsl;
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"

    nixos-wsl.nixosModules.wsl
    <nix-ld/modules/nix-ld.nix>
    <home-manager/nixos>
    ./nix-ld-config.nix
  ];

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "nixos";
    startMenuLaunchers = true;
    docker-native.enable = true;
  };

  environment.sessionVariables = rec {
    PATH = [
      "/opt/vscode-bin"
    ];
    EDITOR = "vim";
  };

  environment.systemPackages = with pkgs; [
    wget
    docker
    ncdu
    curl
    openssl
    zsh
    git
    vim
    bash-completion
  ];

  users.defaultUserShell = pkgs.zsh;
  users.groups.docker.members = [
    "nixos"
  ];

  systemd.services.docker.enable = true;

  nix-ld-config.enable = true;

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "22.05";
}

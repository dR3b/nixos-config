{ config, pkgs, ... }:

let
  pubkey = import ../services/pubkey.nix;
in
{
  imports =
    [
      ./common.nix
      ../services/xfce.nix
    ];

  # boot splash instead of log messages
  boot.plymouth.enable = true;

  # enable audio support
  hardware.pulseaudio.enable = true;

  # install packages
  environment.systemPackages = with pkgs; [
    atom
    meld
    borgbackup
    chromium
    firefox
    keepassx-community
    libreoffice
    mediathekview
    vlc
    simplescreenrecorder
    gnome3.cheese
    python35Packages.xkcdpass
    python35Packages.youtube-dl
    remmina
    virtualbox
    gparted
  ];

  virtualisation.docker.enable = true;

  users.extraUsers.davidak = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" ];
    openssh.authorizedKeys.keys = [ pubkey.davidak ];
  };

  services.syncthing = {
    enable = true;
    user = "davidak";
    dataDir = "/home/davidak/.syncthing";
  };
}

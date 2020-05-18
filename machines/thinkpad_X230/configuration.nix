{ config, pkgs, ... }:

{
  imports =
    [
      <nixos-hardware/lenovo/thinkpad/x230>
      /etc/nixos/hardware-configuration.nix
      ../../profiles/hardware.nix
      ../../profiles/notebook.nix
      ../../profiles/desktop.nix
      ../../profiles/personal.nix
      ../../profiles/communication.nix
      ../../profiles/video-production.nix
      ../../profiles/gaming.nix
    ];

  boot.loader.grub.device = "/dev/sda";
  boot.initrd.luks.devices = [
    { name = "rootfs";
      device = "/dev/disk/by-uuid/3d49cc3e-7771-4116-ac1e-abf4ef0400d0";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  # no access time and continuous TRIM for SSD
  fileSystems."/".options = [ "noatime" "discard" ];
  fileSystems."/boot".options = [ "noatime" "discard" ];

  # intel GPU
  services.xserver.videoDrivers = [ "intel" ];

  networking = {
    hostName = "X230";
    domain = "lan";

    firewall.enable = false;
  };

  # TODO: move
  services.syncthing.dataDir = "/home/davidak/.syncthing";

  # install packages
  environment.systemPackages = with pkgs; [
    electrum
    lollypop
  ];

  # compatible NixOS release
  system.stateVersion = "18.09";
}

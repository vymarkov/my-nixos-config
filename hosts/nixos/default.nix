{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/roles/desktop.nix
    ../../modules/roles/media.nix
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";

  # Age private key for sops-nix (not in git). Generate with:
  #   mkdir -p secrets && age-keygen -o secrets/age-keys.txt
  # Then add the public key to secrets/.sops.yaml.
  sops.age.keyFile = "/etc/nixos/secrets/age-keys.txt";

  system.stateVersion = "25.05";
}

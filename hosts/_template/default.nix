# Template for a new NixOS host. Copy this directory to hosts/<hostname>/ and:
#   1. Run nixos-generate-config on the machine and replace hardware-configuration.nix
#   2. Set networking.hostName and system.stateVersion in default.nix
#   3. Pick role modules (server, desktop, media, ...) in imports
#   4. Add mkHost "<hostname>" to flake.nix nixosConfigurations
{ config, pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/roles/server.nix
    # ../../modules/roles/desktop.nix
    # ../../modules/roles/media.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "CHANGE_ME";

  # Age private key for sops-nix (not in git). See hosts/nixos/default.nix for setup.
  sops.age.keyFile = "/etc/nixos/secrets/age-keys.txt";

  system.stateVersion = "25.05";
}

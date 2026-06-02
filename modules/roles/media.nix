{ config, pkgs, ... }:

{
  imports = [
    ../services/transmission.nix
  ];

  services.plex = {
    enable = true;
    openFirewall = true;
  };
}

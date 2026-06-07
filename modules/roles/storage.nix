{ config, pkgs, ... }:

{
  imports = [
    ../services/garage.nix
    ../services/sairo.nix
  ];
}

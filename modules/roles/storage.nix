{ config, pkgs, ... }:

{
  imports = [
    ../services/minio.nix
    ../services/sairo.nix
  ];

  environment.systemPackages = with pkgs; [
    minio-client
  ];
}

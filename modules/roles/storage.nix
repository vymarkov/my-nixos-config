{ config, pkgs, ... }:

{
  imports = [
    ../services/minio.nix
  ];

  environment.systemPackages = with pkgs; [
    minio-client
  ];
}

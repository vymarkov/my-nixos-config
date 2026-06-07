{ config, lib, pkgs, ... }:

let
  dataDir = "/var/lib/minio/data";
  configDir = "/var/lib/minio/config";
  s3Port = 9000;
  consolePort = 9001;
in
{
  sops.secrets."minio-root" = {
    sopsFile = ../../secrets/minio.yaml;
    owner = "minio";
    mode = "0400";
  };

  # S3 API and web console reachable only via LAN (enp2s0) and Wi-Fi (wlp3s0); tailscale0 is already trusted.
  networking.firewall.interfaces."enp2s0".allowedTCPPorts = [ s3Port consolePort ];
  networking.firewall.interfaces."wlp3s0".allowedTCPPorts = [ s3Port consolePort ];

  services.minio = {
    enable = true;
    dataDir = [ dataDir ];
    inherit configDir;
    listenAddress = ":${toString s3Port}";
    consoleAddress = ":${toString consolePort}";
    rootCredentialsFile = config.sops.secrets."minio-root".path;
    region = "us-east-1";
    browser = true;
  };

  systemd.services.minio.serviceConfig.RequiresMountsFor = lib.mkAfter [ dataDir ];
}

{ config, lib, pkgs, ... }:

let
  metadataDir = "/var/lib/garage/meta";
  garageDataPath = "/var/lib/garage/data";
  garageDataCapacity = "200G";
in
{
  sops.secrets."garage-rpc-secret" = {
    sopsFile = ../../secrets/garage.yaml;
  };

  sops.templates."garage.toml" = {
    owner = "root";
    mode = "0444";
    content = ''
metadata_dir = "${metadataDir}"
db_engine = "lmdb"
replication_factor = 1

data_dir = [
  { path = "${garageDataPath}", capacity = "${garageDataCapacity}" },
]

rpc_secret = "${config.sops.placeholder."garage-rpc-secret"}"
rpc_bind_addr = "127.0.0.1:3901"
rpc_public_addr = "127.0.0.1:3901"

[s3_api]
api_bind_addr = "[::]:3900"
s3_region = "garage"

[admin]
api_bind_addr = "127.0.0.1:3903"
'';
  };

  networking.firewall.interfaces."enp2s0".allowedTCPPorts = lib.mkAfter [ 3900 ];
  networking.firewall.interfaces."wlp3s0".allowedTCPPorts = lib.mkAfter [ 3900 ];

  # CLI wrapper and systemd read GARAGE_CONFIG_FILE; /etc/garage.toml from settings is incomplete.
  environment.etc."garage/garage.env".text = ''
    GARAGE_CONFIG_FILE=${config.sops.templates."garage.toml".path}
  '';
  environment.etc."garage.toml".enable = lib.mkForce false;

  services.garage = {
    enable = true;
    package = pkgs.garage_2;
    logLevel = "info";
    environmentFile = "/etc/garage/garage.env";
    settings = {
      metadata_dir = metadataDir;
      data_dir = [
        {
          path = garageDataPath;
          capacity = garageDataCapacity;
        }
      ];
    };
  };

  systemd.services.garage = {
    restartTriggers = lib.mkAfter [ config.sops.templates."garage.toml".file ];
    serviceConfig.ExecStart = lib.mkForce "${pkgs.garage_2}/bin/garage -c ${config.sops.templates."garage.toml".path} server";
    serviceConfig.RequiresMountsFor = lib.mkAfter [ garageDataPath ];
  };

  systemd.tmpfiles.rules = [
    "d ${metadataDir}  0750 root root - -"
    "d ${garageDataPath} 0750 root root - -"
  ];
}

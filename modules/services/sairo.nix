{ config, pkgs, ... }:

let
  dataDir = "/var/lib/sairo/data";
  composeDir = "/etc/nixos/compose/sairo";
  sairoPort = 8000;
in
{
  sops.secrets."sairo-env" = {
    sopsFile = ../../secrets/sairo.yaml;
    path = "${composeDir}/.env";
    mode = "0400";
  };

  virtualisation.podman.enable = true;

  # Web UI reachable only via LAN (enp2s0) and Wi-Fi (wlp3s0); tailscale0 is already trusted.
  networking.firewall.interfaces."enp2s0".allowedTCPPorts = [ sairoPort ];
  networking.firewall.interfaces."wlp3s0".allowedTCPPorts = [ sairoPort ];

  systemd.services.sairo-compose = {
    description = "Sairo S3 browser (podman compose)";
    after = [ "network-online.target" "minio.service" "podman.socket" ];
    requires = [ "minio.service" ];
    wants = [ "network-online.target" "podman.socket" ];
    wantedBy = [ "multi-user.target" ];
    # podman compose delegates to docker-compose when no compose plugin is bundled
    path = with pkgs; [ podman docker-compose ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = composeDir;
    };
    script = "${pkgs.podman}/bin/podman compose up -d --remove-orphans";
    preStop = "${pkgs.podman}/bin/podman compose down";
  };

  # Sairo container runs as UID 1000 (non-root); host bind mount must match.
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 1000 1000 - -"
  ];
}

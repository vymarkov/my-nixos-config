{ config, lib, pkgs, ... }:

{
  sops.secrets."sairo-admin-pass" = {
    sopsFile = ../../secrets/garage.yaml;
  };
  sops.secrets."sairo-jwt-secret" = {
    sopsFile = ../../secrets/garage.yaml;
  };
  sops.secrets."sairo-s3-access-key" = {
    sopsFile = ../../secrets/garage.yaml;
  };
  sops.secrets."sairo-s3-secret-key" = {
    sopsFile = ../../secrets/garage.yaml;
  };

  sops.templates."sairo-env" = {
    owner = "root";
    mode = "0400";
    content = ''
      S3_ENDPOINT=http://127.0.0.1:3900
      S3_ACCESS_KEY=${config.sops.placeholder."sairo-s3-access-key"}
      S3_SECRET_KEY=${config.sops.placeholder."sairo-s3-secret-key"}
      S3_REGION=garage
      S3_PATH_STYLE=true
      ADMIN_USER=admin
      ADMIN_PASS=${config.sops.placeholder."sairo-admin-pass"}
      JWT_SECRET=${config.sops.placeholder."sairo-jwt-secret"}
      SECURE_COOKIE=false
      DB_DIR=/data
    '';
  };

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  networking.firewall.interfaces."enp2s0".allowedTCPPorts = lib.mkAfter [ 8000 ];
  networking.firewall.interfaces."wlp3s0".allowedTCPPorts = lib.mkAfter [ 8000 ];

  virtualisation.oci-containers.containers.sairo = {
    image = "docker.io/stephenjr002/sairo:3.2.0";
    ports = [ "8000:8000" ];
    volumes = [ "/var/lib/sairo:/data" ];
    environmentFiles = [ config.sops.templates."sairo-env".path ];
    extraOptions = [ "--network=host" ];
  };

  systemd.services."podman-sairo" = {
    after = lib.mkAfter [ "garage.service" ];
    requires = lib.mkAfter [ "garage.service" ];
    restartTriggers = lib.mkAfter [ config.sops.templates."sairo-env".file ];
  };

  # Sairo image runs as UID/GID 1000 (appuser); host dir must be writable by that user.
  systemd.tmpfiles.rules = [
    "d /var/lib/sairo 0750 1000 1000 - -"
    "Z /var/lib/sairo 0750 1000 1000 - -"
  ];
}

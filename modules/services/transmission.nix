{ config, pkgs, ... }:

let
  home = config.services.transmission.home;
  downloadDir = "${home}/downloads";
  incompleteDir = "${home}/incomplete";
in
{
  sops.secrets."transmission-rpc" = {
    sopsFile = ../../secrets/transmission.yaml;
    owner = "transmission";
    mode = "0400";
  };

  # mark must read/write completed and in-progress downloads
  users.users.mark.extraGroups = [ "transmission" ];

  # Web UI / RPC reachable only via LAN (enp2s0) and Wi-Fi (wlp3s0); tailscale0 is already trusted.
  networking.firewall.interfaces."enp2s0".allowedTCPPorts = [ 9091 ];
  networking.firewall.interfaces."wlp3s0".allowedTCPPorts = [ 9091 ];

  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    openFirewall = false; # do not expose inbound peer port for seeding

    settings = {
      download-dir = downloadDir;
      incomplete-dir-enabled = true;
      incomplete-dir = incompleteDir;
      umask = 2; # new files 664, dirs 775 — group transmission can access

      port-forwarding-enabled = false;
      # Downloads use outbound connections only; peers cannot initiate inbound connections.

      rpc-enabled = true;
      rpc-port = 9091;
      rpc-bind-address = "0.0.0.0"; # listens on all ifaces; exposure gated by firewall (enp2s0 + wlp3s0 + tailscale0)
      rpc-whitelist-enabled = false; # allow RPC from LAN and Tailscale without IP whitelist
      rpc-host-whitelist-enabled = false; # allow any Host header (needed for Tailscale hostname)
    };

    credentialsFile = config.sops.secrets."transmission-rpc".path;
  };

  # Create download dirs and ensure mark (group transmission) can read/write them.
  # "d" creates the directory if missing; "Z" recursively fixes ownership/mode.
  systemd.tmpfiles.rules = [
    "d  ${home}           0750 transmission transmission - -"
    "d  ${downloadDir}    0775 transmission transmission - -"
    "d  ${incompleteDir}  0775 transmission transmission - -"
    "Z  ${downloadDir}    0775 transmission transmission - -"
    "Z  ${incompleteDir}  0775 transmission transmission - -"
  ];
}

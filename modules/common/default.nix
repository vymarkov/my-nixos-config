{ config, pkgs, ... }:

{
  # Required for Remote-SSH and dynamically linked binaries on NixOS.
  programs.nix-ld.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;

  services.tailscale.enable = true;

  # Tailscale usually opens the firewall for tailscale0; this keeps Exit Node support reliable.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Lisbon";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  users.users.mark = {
    isNormalUser = true;
    description = "mark";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    bash
    age  # age-keygen + age encrypt/decrypt; used to manage sops-nix age keys
    sops  # sops encrypt/decrypt; used to manage sops-nix secrets
    openssl  # openssl encrypt/decrypt; used to manage sops-nix secrets
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}

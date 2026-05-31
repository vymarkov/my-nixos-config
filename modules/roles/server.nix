{ config, pkgs, lib, ... }:

{
  # Headless baseline: no desktop environment or display manager.
  services.xserver.enable = lib.mkForce false;

  # Console-only systems still benefit from a minimal editor for recovery.
  environment.systemPackages = with pkgs; [
    neovim
  ];
}

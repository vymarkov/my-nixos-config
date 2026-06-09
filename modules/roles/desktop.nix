{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;

  programs._1password.enable = true;

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "mark" ];
  };

  # Zen Browser is not in 1Password's default trusted list.
  # Binary name from zen-browser-flake wrapFirefox; verify with: ps aux | grep -i zen
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      .zen-wrapped
      zen-bin
    '';
    mode = "0755";
  };
}

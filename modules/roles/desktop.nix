{ config, pkgs, lib, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # Tree tiling is handled by the Forge GNOME Shell extension (home-manager).

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Apple Magic Keyboard: remap Command <-> Control at evdev level (works in
  # GNOME Wayland, X11, and TTY). XKB/gsettings alone did not apply the swap.
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        leftmeta = "leftcontrol";
        rightmeta = "rightcontrol";
        leftcontrol = "leftmeta";
        rightcontrol = "rightmeta";
      };
    };
  };

  # Function keys as F1-F12 by default when hid_apple binds to the keyboard.
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  # hyprflake left catppuccin cursor in dconf; GNOME only ships Adwaita by default.
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        cursor-theme = "Adwaita";
        cursor-size = lib.gvariant.mkInt32 24;
      };
    }
  ];

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

  environment.systemPackages = with pkgs; [
    google-chrome
  ];

  programs._1password.enable = true;

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "mark" ];
  };

  # Zen and Chrome are not in 1Password's default trusted list.
  # Zen binary from zen-browser-flake wrapFirefox; verify with: ps aux | grep -i zen
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      .zen-wrapped
      zen-bin
      google-chrome
      google-chrome-stable
    '';
    mode = "0755";
  };
}

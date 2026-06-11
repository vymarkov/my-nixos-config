{ config, pkgs, ... }:

{
  hyprflake = {
    user.username = "mark";

    desktop.keyboard = {
      layout = "us";
      variant = "";
    };

    # Avoid apple-fonts flake (stale SF-Pro.dmg narHash in hyprflake lock).
    style.fonts = {
      monospace = {
        name = "JetBrains Mono";
        package = pkgs.jetbrains-mono;
      };
      sansSerif = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };
      serif = {
        name = "Noto Serif";
        package = pkgs.noto-fonts;
      };
    };
  };

  # GNOME/GDM removed; stylix gnome target only applies when those are enabled.
  stylix.targets.gnome.enable = false;
}

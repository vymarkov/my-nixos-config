# Minimal Hyprland config alongside GNOME.
#
# Apple keyboard: keyd swaps physical Cmd <-> Ctrl at evdev level. Aerospace-style
# Alt binds are unchanged. Hyprland $mod (SUPER) maps to the physical Control key.
{ config, pkgs, lib, ... }:

let
  workspaceCount = 9;

  workspaceBinds = lib.flatten (lib.imap1 (i: _: [
    "ALT, ${toString i}, workspace, ${toString i}"
    "ALT SHIFT, ${toString i}, movetoworkspace, ${toString i}"
  ]) (lib.genList (_: _) workspaceCount));

  launcherBinds = [
    "ALT, W, exec, kitty"
    "ALT, Z, exec, zen-beta"
    "ALT, V, exec, cursor"
    "ALT, B, exec, google-chrome-stable"
    "ALT, F, exec, firefox"
    "ALT, TAB, workspace, previous"
  ];

  modBinds = [
    "$mod, left, movefocus, l"
    "$mod, right, movefocus, r"
    "$mod, up, movefocus, u"
    "$mod, down, movefocus, d"
    "$mod SHIFT, left, movewindow, l"
    "$mod SHIFT, right, movewindow, r"
    "$mod SHIFT, up, movewindow, u"
    "$mod SHIFT, down, movewindow, d"
    "$mod, Q, killactive"
    "$mod, P, togglefloating"
    "$mod, RETURN, exec, $terminal"
  ];
in
{
  programs.kitty.enable = true;

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.hyprpolkitagent.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    systemd.enable = false; # UWSM manages graphical-session targets

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";

      monitor = ", preferred, auto, 1";

      general = {
        gaps_in = 20;
        gaps_out = 10;
        border_size = 0;
        layout = "dwindle";
      };

      decoration = {
        rounding = 0;
      };

      animations = {
        enabled = false;
      };

      windowrulev2 = [
        "float, class:^(1Password)$"
      ];

      bind = workspaceBinds ++ launcherBinds ++ modBinds;
    };
  };
}

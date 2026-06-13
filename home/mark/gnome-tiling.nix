# Aerospace tiling workflow ported to GNOME via Forge + auto-move-windows.
#
# After rebuild, verify wmClass names for float/move rules:
#   gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell \
#     --method org.gnome.Shell.Eval \
#     'global.display.focus_window.get_wm_class()'
# (Eval may be denied on GNOME 45+; use Forge preferences instead.)
{ config, pkgs, lib, ... }:

let
  forgeUuid = "forge@jmmaranan.com";
  autoMoveUuid = "auto-move-windows@gnome-shell-extensions.gcampax.github.com";
  goToLastWorkspaceUuid = "gnome-shell-go-to-last-workspace@github.com";

  moveWindowToWorkspace = ws: pkgs.writeShellScript "move-window-to-ws-${toString ws}" ''
    ${pkgs.wtype}/bin/wtype -M alt -M shift -P ${toString ws}
  '';

  # GNOME Shell Eval/FocusApp are denied to external callers on GNOME 45+, so use
  # wezterm's mux CLI to activate an existing pane instead of spawning a new window.
  focusWezterm = pkgs.writeShellScript "focus-wezterm" ''
    pane_id=$(${pkgs.wezterm}/bin/wezterm cli list 2>/dev/null \
      | ${pkgs.gawk}/bin/gawk 'NR>1 {print $1, $3}' \
      | sort -n \
      | head -1 \
      | ${pkgs.gawk}/bin/awk '{print $2}') || true

    if [ -n "''${pane_id:-}" ]; then
      ${pkgs.wezterm}/bin/wezterm cli activate-pane --pane-id "$pane_id"
      exit 0
    fi

    exec ${pkgs.wezterm}/bin/wezterm start --cwd .
  '';

  customLauncherBindings = [
    { id = "launch-wezterm"; binding = "<Alt>w"; command = "${focusWezterm}"; }
    { id = "launch-zen"; binding = "<Alt>z"; command = "zen-beta"; }
    { id = "launch-cursor"; binding = "<Alt>v"; command = "cursor"; }
    { id = "launch-chrome"; binding = "<Alt>b"; command = "google-chrome-stable"; }
    { id = "launch-firefox"; binding = "<Alt>f"; command = "firefox"; }
    { id = "move-to-ws-6-via-7"; binding = "<Alt><Shift>7"; command = "${moveWindowToWorkspace 6}"; }
    { id = "move-to-ws-5-via-8"; binding = "<Alt><Shift>8"; command = "${moveWindowToWorkspace 5}"; }
  ];

  customKeybindingPaths = lib.imap0 (i: binding:
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${binding.id}/"
  ) customLauncherBindings;

  customKeybindingSettings = lib.foldl' (acc: binding:
    acc // {
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${binding.id}" = {
        name = binding.id;
        binding = binding.binding;
        command = binding.command;
      };
    }
  ) { } customLauncherBindings;

  workspaceSwitchBindings = lib.listToAttrs (lib.imap1 (i: _:
    lib.nameValuePair "switch-to-workspace-${toString i}" [ "<Alt>${toString i}" ]
  ) (lib.genList (_: _) 9));

  workspaceMoveBindings = lib.listToAttrs (lib.filter (attr:
    !(lib.elem attr.name [ "move-to-workspace-7" "move-to-workspace-8" ])
  ) (lib.imap1 (i: _:
    lib.nameValuePair "move-to-workspace-${toString i}" [ "<Alt><Shift>${toString i}" ]
  ) (lib.genList (_: _) 9)));
in
{
  home.packages = with pkgs; [
    gnomeExtensions.forge
    gnomeExtensions.auto-move-windows
    gnomeExtensions.go-to-last-workspace
    wezterm
    wtype
  ];

  home.file.".config/forge/config/windows.json" = {
    source = ./forge-windows.json;
    force = true;
  };

  dconf.settings =
    customKeybindingSettings
    // {
      "org/gnome/shell" = {
        enabled-extensions = [
          forgeUuid
          autoMoveUuid
          goToLastWorkspaceUuid
        ];
      };

      "org/gnome/shell/extensions/go-to-last-workspace" = {
        shortcut-key = [ "<Alt>Tab" ];
      };

      "org/gnome/mutter" = {
        dynamic-workspaces = false;
      };

      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 11;
      };

      "org/gnome/desktop/wm/keybindings" = workspaceSwitchBindings // workspaceMoveBindings // {
        # Alt+Tab is handled by go-to-last-workspace (shell-level binding).
        switch-to-workspace-last = [ ];
        switch-applications = [ "<Super>Tab" ];
        switch-applications-backward = [ "<Super><Shift>Tab" ];
        switch-windows = [ ];
        switch-windows-backward = [ ];
        toggle-fullscreen = [ "<Alt><Ctrl><Shift>f" ];
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = customKeybindingPaths;
      };

      "org/gnome/shell/extensions/forge" = {
        window-gap-size = 20;
        tiling-mode-enabled = true;
        move-pointer-focus-enabled = true;
        primary-layout-mode = "tiling";
      };

      "org/gnome/shell/extensions/forge/keybindings" = {
        window-toggle-float = [ "<Alt><Ctrl>f" ];
        window-move-left = [ "<Alt><Shift>h" ];
        window-move-down = [ "<Alt><Shift>j" ];
        window-move-up = [ "<Alt><Shift>k" ];
        window-move-right = [ "<Alt><Shift>l" ];
        con-split-layout-toggle = [ "<Alt>slash" ];
        con-stacked-layout-toggle = [ "<Alt>comma" ];
        window-resize-right-increase = [ "<Alt><Shift>equal" ];
        window-resize-left-decrease = [ "<Alt><Shift>minus" ];
      };

      "org/gnome/shell/extensions/auto-move-windows" = {
        application-list = [
          "zen-beta.desktop:1"
          "org.wezfurlong.wezterm.desktop:9"
          "cursor.desktop:3"
          "google-chrome.desktop:5"
        ];
      };
    };
}

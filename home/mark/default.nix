{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    policies = let
      mkExtensionSettings = builtins.mapAttrs (_: slug: {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
        installation_mode = "force_installed";
      });
    in {
      ExtensionSettings = mkExtensionSettings {
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = "vimium-ff";
      };
    };

    profiles.default = {
      isDefault = true;

      spacesForce = true;
      spaces = {
        Home = {
          id = "2fea1ccf-6544-4902-8e8f-7d286ff2cc8b";
          position = 1000;
          icon = "🏠";
        };
        Work = {
          id = "588fc98b-ed0a-4b74-9d1f-4187edab39aa";
          position = 2000;
          icon = "💼";
        };
      };

      settings = {
        # Smooth scrolling (keep enabled)
        "general.smoothScroll" = true;
        "general.smoothScroll.msdPhysics.enabled" = true;

        # Mouse wheel: main speed control (default ~100)
        "mousewheel.default.delta_multiplier_y" = 50;
        "mousewheel.default.delta_multiplier_x" = 50;

        # Less acceleration on rapid scroll bursts
        "mousewheel.acceleration.factor" = 3;
        "mousewheel.acceleration.start" = 30;

        # Trackpad: smaller step per gesture
        "mousewheel.min_line_scroll_amount" = 1;
        "toolkit.scrollbox.verticalScrollDistance" = 3;
      };
    };
  };

  programs.vscode = {
    enable = true;
    package = inputs.code-cursor-nix.packages.${pkgs.stdenv.hostPlatform.system}.cursor;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
    ];
  };
 
  home.stateVersion = "25.05";
  home.username = "mark";
  home.homeDirectory = "/home/mark";

  home.packages = with pkgs; [
    neovim
    git
    gh
    nixd
  ];
}

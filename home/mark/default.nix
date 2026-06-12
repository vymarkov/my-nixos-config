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

  home.stateVersion = "25.05";
  home.username = "mark";
  home.homeDirectory = "/home/mark";

  home.packages = with pkgs; [
    neovim
    git
    gh
  ];
}

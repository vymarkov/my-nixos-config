{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

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

{ config, pkgs, lib, ... }:

{
  home.stateVersion = "25.05";
  home.username = "mark";
  home.homeDirectory = "/home/mark";

  home.packages = with pkgs; [
    neovim
    git
    gh
  ];
}

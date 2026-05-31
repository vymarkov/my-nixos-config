# Replace this file with output from nixos-generate-config on the target machine.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
}

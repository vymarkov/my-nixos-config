{ config, pkgs, ... }:

{
  services.printing.enable = true;

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

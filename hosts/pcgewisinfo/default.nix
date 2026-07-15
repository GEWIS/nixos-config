{ ... }:

{
  imports = [
    ./boot.nix
    ./disko.nix
    ./kiosk.nix
    ./persistence.nix
    ./comin.nix
    ./secrets.nix
    ./netbird.nix
    ./networking.nix
    ./printers.nix
    ./schedule.nix
  ];

  system.stateVersion = "26.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  time.timeZone = "Europe/Amsterdam";
  nix = {
    settings = {
      substituters = [ "https://gewis.cachix.org" ];
      trusted-public-keys = [
        "gewis.cachix.org-1:bOcor+MaaLuUJN0Yj/IHCXsOQWm/RxSokm6BHGcbF5k="
      ];

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [
        "cbc"
        "root"
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}

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
    ./schedule.nix
    ./debug.nix
  ];

  system.stateVersion = "26.05";

  boot.loader.systemd-boot.enable = true;
  # Kiosk firmware often drops NVRAM boot entries and falls through to PXE.
  # canTouchEfiVariables=false makes bootctl install the removable fallback
  # path (\EFI\BOOT\BOOTX64.EFI) that firmware boots without an NVRAM entry.
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "pcgewisinfo";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Amsterdam";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}

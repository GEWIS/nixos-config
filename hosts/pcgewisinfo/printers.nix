{ pkgs, lib, ... }:
{
  services.printing = {
    enable = true;
    drivers = lib.singleton (
      pkgs.linkFarm "drivers" [
        {
          name = "share/cups/model/PSGEWIS1.ppd";
          path = ./assets/PSGEWIS1.ppd;
        }
        {
          name = "share/cups/model/PSGEWIS2.ppd";
          path = ./assets/PSGEWIS1.ppd;
        }
      ]
    );
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "PSGEWIS1";
        deviceUri = "ipp://10.0.0.10:631/ipp/print";
        model = "PSGEWIS1.ppd";
      }
      {
        name = "PSGEWIS2";
        deviceUri = "ipp://10.0.0.11:631/ipp/print";
        model = "PSGEWIS2.ppd";
      }
    ];
    ensureDefaultPrinter = "PSGEWIS1";
  };

  services.geprint = {
    enable = true;
    address = "0.0.0.0";
    port = 8080;
    openFirewall = false;
  };

  networking.firewall.interfaces."nb-netbird".allowedTCPPorts = [ 8080 ];
}

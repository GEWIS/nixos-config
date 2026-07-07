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
    ];
    ensureDefaultPrinter = "PSGEWIS1";
  };
}

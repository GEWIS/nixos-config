{ ... }:
{
  services.printing = {
    enable = true;
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "PSGEWIS1";
        deviceUri = "ipp://10.0.0.10:631/ipp/print";
        model = "everywhere";
      }
      {
        name = "PSGEWIS2";
        deviceUri = "ipp://10.0.0.11:631/ipp/print";
        model = "everywhere";
      }
    ];
    ensureDefaultPrinter = "PSGEWIS1";
  };

  services.geprint = {
    enable = true;
    address = "0.0.0.0"; # reachable on the LAN
    port = 8080;
    openFirewall = true;
  };
}

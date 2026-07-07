{ config, ... }:

{
  sops.secrets.netbird-setupkey = {
    owner = "root";
    restartUnits = [ "netbird-login.service" ];
  };
  services = {
    netbird.clients.netbird = {
      autoStart = true;
      port = 51820;
      hardened = false;
      config = {
        ServerSSHAllowed = true;
      };
      environment = {
        NB_MANAGEMENT_URL = "https://nb.gewis.nl";
        NB_EXTRA_DNS_LABELS = "pcgewisinfo";
      };
      login = {
        enable = true;
        setupKeyFile = config.sops.secrets.netbird-setupkey.path;
        systemdDependencies = [ "sops-install-secrets.service" ];
      };
    };

    resolved.enable = true;

    openssh.enable = true;
  };
}

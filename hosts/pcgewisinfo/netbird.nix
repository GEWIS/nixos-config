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
      };
    };

    resolved.enable = true;

    openssh.enable = true;
    openssh.hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
  environment.persistence."/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
}

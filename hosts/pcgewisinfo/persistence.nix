_:

{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/lib/comin"
      "/var/log/journal"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}

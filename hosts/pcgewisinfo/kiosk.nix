{ config, pkgs, ... }:

let
  kioskLauncher = pkgs.writeShellScript "kiosk-launch" ''
    url="$(cat ${config.sops.secrets.kioskUrl.path})"
    exec ${pkgs.chromium}/bin/chromium \
      --kiosk --incognito --noerrdialogs --disable-infobars \
      --no-first-run --start-fullscreen \
      --check-for-update-interval=31536000 \
      "$url"
  '';
in
{
  users = {
    mutableUsers = false;
    allowNoPasswordLogin = true;

    groups.gewis.gid = 1000;
    users.gewis = {
      isNormalUser = true;
      description = "GEWIS kiosk";
      uid = 1000;
      group = "gewis";
      hashedPassword = "";
      extraGroups = [
        "video"
        "audio"
      ];
    };
  };

  services.cage = {
    enable = true;
    user = "gewis";
    program = "${kioskLauncher}";
    extraArguments = [ "-d" ];
  };

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  environment.systemPackages = [ pkgs.chromium ];
}

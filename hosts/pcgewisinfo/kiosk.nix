{ config, pkgs, ... }:

let
  kioskLauncher = pkgs.writeShellScript "kiosk-launch" ''
    url="$(cat ${config.sops.secrets.kioskUrl.path})"
    # Wait until the kiosk URL is reachable before launching.
    until ${pkgs.curl}/bin/curl -sSf --max-time 5 -o /dev/null "$url"; do
      sleep 2
    done
    exec ${pkgs.chromium}/bin/chromium \
      --app="$url" \
      --ozone-platform=wayland \
      --user-data-dir="$(mktemp -d)" \
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

    users.cbc = {
      isNormalUser = true;
      hashedPassword = "";
      extraGroups = [ "wheel" ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services.cage = {
    enable = true;
    user = "gewis";
    program = "${kioskLauncher}";
    extraArguments = [ "-d" ];
  };

  # cage draws a cursor whenever libinput reports a pointer device, and uses
  # client-side cursors so no XCURSOR theme can hide it. Tell libinput to ignore
  # every mouse instead: no pointer device -> no cursor. Keyboards are separate
  # device nodes and keep working.
  services.udev.extraRules = ''
    SUBSYSTEM=="input", ENV{ID_INPUT_MOUSE}=="1", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  systemd.services.cage-tty1 = {
    startLimitIntervalSec = 60;
    startLimitBurst = 10;
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  environment.systemPackages = [ pkgs.chromium ];
}

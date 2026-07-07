{ pkgs, ... }:

let
  # Arm RTC wake for the next 08:00 local time, then power off.
  # RTC wake from S5 is firmware-dependent; if the box does not power on by
  # itself, enable "Wake on RTC"/"Auto Power On" in BIOS as the reliable path.
  poweroff = pkgs.writeShellScript "daily-poweroff" ''
    set -eu
    ${pkgs.util-linux}/bin/rtcwake -m no -t "$(${pkgs.coreutils}/bin/date -d 'tomorrow 08:00' +%s)"
    ${pkgs.systemd}/bin/systemctl poweroff
  '';
in
{
  systemd.services.daily-poweroff = {
    description = "Arm RTC wake for 08:00 and power off";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = poweroff;
    };
  };

  systemd.timers.daily-poweroff = {
    description = "Power off daily at 22:00";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 22:00:00";
      Persistent = false;
    };
  };
}

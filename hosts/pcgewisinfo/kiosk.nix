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

  # A cursor theme whose pointers are all a single transparent pixel, so the
  # mouse is invisible on the kiosk while input still works. cage/wlroots picks
  # it up via XCURSOR_THEME/XCURSOR_PATH below.
  hiddenCursorTheme = pkgs.runCommand "hidden-cursor" { nativeBuildInputs = [ pkgs.xcursorgen pkgs.python3 ]; } ''
    dir="$out/share/icons/hidden/cursors"
    mkdir -p "$dir"
    # Emit a 1x1 fully transparent RGBA PNG (stdlib zlib, no vendored blob).
    python3 - blank.png <<'PY'
    import sys, struct, zlib
    def chunk(t, d): return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
    sig = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", 1, 1, 8, 6, 0, 0, 0)
    idat = zlib.compress(b"\x00\x00\x00\x00\x00")
    open(sys.argv[1], "wb").write(sig + chunk(b"IHDR", ihdr) + chunk(b"IDAT", idat) + chunk(b"IEND", b""))
    PY
    echo "24 0 0 blank.png" > blank.cfg
    xcursorgen blank.cfg "$dir/left_ptr"
    # Alias every common pointer name to the same transparent cursor.
    for name in default pointer text hand hand1 hand2 xterm crosshair \
                top_left_arrow left_ptr_watch watch progress; do
      ln -sf left_ptr "$dir/$name"
    done
    printf '[Icon Theme]\nName=hidden\n' > "$out/share/icons/hidden/index.theme"
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
    environment = {
      XCURSOR_THEME = "hidden";
      XCURSOR_PATH = "${hiddenCursorTheme}/share/icons";
    };
  };

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

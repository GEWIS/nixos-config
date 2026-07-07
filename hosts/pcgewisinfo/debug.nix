# TEMPORARY bootstrap access — DELETE once netbird SSH works.
# Password is "changeme-gewis". Opens LAN SSH so the box is reachable
# before the netbird tunnel is up.
{ ... }:

{
  users.users.root.hashedPassword = "$6$DzQDp/XOU7KH16tH$dZRkr9A6nY6YE1g9VzTO6HtAootHdW9GqdW6Wno/mx68nCkAokuA3eylPU/IheI.D7owtp87.r9iM5fy77Nuv0";

  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.settings.PasswordAuthentication = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
}

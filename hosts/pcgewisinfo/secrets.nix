{ ... }:

{
  sops = {
    age.keyFile = "/persist/var/lib/sops-nix/key.txt";
    defaultSopsFile = ./secrets/secrets.yaml;
    secrets.kioskUrl = {
      owner = "gewis";
    };
    secrets.cbcPassword.neededForUsers = true;
  };
}

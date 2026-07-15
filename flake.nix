{
  description = "GEWIS CBC hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    geprint = {
      url = "github:GEWIS/GEPRINT";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      comin,
      disko,
      impermanence,
      sops-nix,
      geprint,
      ...
    }:
    {
      nixosConfigurations.pcgewisinfo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          comin.nixosModules.comin
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          geprint.nixosModules.default
          ./hosts/pcgewisinfo
        ];
      };
    };
}

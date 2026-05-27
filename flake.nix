{
  description = "tenequm's personal Nix packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    systems = [ "aarch64-darwin" "x86_64-linux" ];
    forEachSystem = nixpkgs.lib.genAttrs systems;
  in {
    packages = forEachSystem (system: let
      pkgs = import nixpkgs { inherit system; };
    in {
      pond = pkgs.callPackage ./pkgs/pond { };
    });

    overlays.default = final: prev: {
      pond = self.packages.${final.system}.pond;
    };
  };
}

let
  nixpkgsSrc = builtins.fetchTarball {
    # nixpkgs-19.03 as of 2019/04/15.
    url = "https://github.com/NixOS/nixpkgs/archive/29b0d4d0b600f8f5dd0b86e3362a33d4181938f9.tar.gz";
    sha256 = "10cafssjk6wp7lr82pvqh8z7qiqwxpnh8cswnk1fbbw2pacrqxr1";
  };

  overlay = self: super: {
    our-haskell-pkg-set = self.haskell.packages.ghc8104.override {
      overrides = hself: hsuper: {

        package1 = hself.callCabal2nix "package1" ./package1 { };

        package2 = hself.callCabal2nix "package2" ./package2 { };

        our-local-pkgs = [
          hself.package1
          hself.package2
        ];

        conduit = hself.callHackage "conduit" "1.3.1" { };
      };
    };

    shell = self.our-haskell-pkg-set.shellFor {
      packages = pkgs: pkgs.our-local-pkgs;
      nativeBuildInputs = [
        self.cabal-install
        self.haskellPackages.ghcid
      ];
    };

    our-project-exes = self.buildEnv {
      name = "nix-cabal-example-project";
      paths = self.our-haskell-pkg-set.our-local-pkgs;
      extraOutputsToInstall = [ "dev" "out" ];
    };
  };

in

import nixpkgsSrc {
  overlays = [ overlay ];
}

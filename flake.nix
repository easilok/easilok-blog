{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs, ... }:
    let
      # system should match the system you are running on
      system = "x86_64-linux";
    in {
      devShells."${system}".default =
        let pkgs = import nixpkgs { inherit system; };
        in pkgs.mkShell {
          # openssl.dev
          packages = with pkgs; [ guile guile-commonmark haunt ];
          shellHook = ''
            echo Haunt dev shell
            # export LD_LIBRARY_PATH=${pkgs.openssl.out}/lib
          '';
        };
    };
}

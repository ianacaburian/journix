{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs }: 
    let pkgs = nixpkgs.legacyPackages.x86_64-darwin;
    in {
      packages.x86_64-darwin.hello = pkgs.hello;

      devShell.x86_64-darwin = pkgs.mkShell { 
        buildInputs = [
          self.packages.x86_64-darwin.hello
          pkgs.cowsay
        ];
      };
    };
}
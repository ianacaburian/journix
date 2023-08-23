let
  pkgs = import <nixpkgs> { };
in
{
  hello = pkgs.callPackage ./hello.nix { };
  icat = pkgs.callPackage ./icat.nix { };
}
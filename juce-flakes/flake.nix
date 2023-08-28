{
  description = "juce flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    juce-src = {
      url = "github:juce-framework/JUCE/7.0.7";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, juce-src }: 
    let 
    pkgs = nixpkgs.legacyPackages.x86_64-darwin;
    juce = pkgs.darwin.apple_sdk_11_0.stdenv.mkDerivation {
      name = "juce";
      src = juce-src;
      nativeBuildInputs = [ pkgs.cmake ];
      buildInputs = with pkgs.darwin.apple_sdk_11_0.frameworks; [
        Cocoa 
        MetalKit
        WebKit
      ];
      configurePhase = ''
        runHook preConfigure
        cmake -B cmake-build-install -DCMAKE_INSTALL_PREFIX=$out
        runHook postConfigure
      '';
      buildPhase = ''
        runHook preBuild
        cmake --build cmake-build-install --target install
        runHook postBuild
      '';
    };
    in {
      devShell.x86_64-darwin = pkgs.mkShell { 
        name = "juce-flakes shell";
        buildInputs = [
          pkgs.cmake
          juce
        ];
      };
    };
}
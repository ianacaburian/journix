{
  description = "juce flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";
    utils.url = "github:numtide/flake-utils";

    juce = {
      type = "github";
      owner = "juce-framework";
      repo = "JUCE";
      rev = "7.0.7";
      sha256 = "r+Wf/skPDexm3rsrVBoWrygKvV9HGlCQd7r0iHr9avM=";
      flake = false;
      # rev = "6d7bf9281a2e500e734fe46840ab7a2b1cbde544";
      # sha256 = "LJRPKNGKn5oS3HWvs4m05ktdta58po6WJA+YRf94Ftw=";
    };
  };

  outputs = { self, nixpkgs, juce, ... }@inputs: 
    inputs.utils.lib.eachSystem [
      "x86_64-darwin"
    ] (system: 
      let 
      pkgs = import nixpkgs { inherit system; };
      in 
      {
        packages.system.juce = pkgs.stdenv.mkDerivation {
          name = "juce";
          src = juce;
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

        devShell = pkgs.mkShell {
          name = "pg shell";
          packages = with pkgs; [
            cmake 
            self.packages.system.juce
          ];
        };
      }
    );
}
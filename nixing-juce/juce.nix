let
pkgs = import <nixpkgs> {};
in
pkgs.darwin.apple_sdk_11_0.stdenv.mkDerivation {
  pname = "juce";
  version = "7.0.7";
  src = pkgs.fetchFromGitHub {
    owner = "juce-framework";
    repo = "juce";
    rev = "7.0.7";
    sha256 = "r+Wf/skPDexm3rsrVBoWrygKvV9HGlCQd7r0iHr9avM=";
  };

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
}

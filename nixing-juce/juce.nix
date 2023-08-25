let
pkgs = import <nixpkgs> {};
in
pkgs.darwin.apple_sdk_11_0.stdenv.mkDerivation {
  name = "juce";
 
  src = pkgs.fetchFromGitHub {
    owner = "juce-framework";
    repo = "juce";
    rev = "7.0.7";
    sha256 = "fsYoFYRhJZlrTw5VYA1ZPEXTTseWIVfhZjQUxVwwYTk=";
    deepClone = true;
  };

  nativeBuildInputs = with pkgs; [ cmake ];

  buildInputs = with pkgs.darwin.apple_sdk_11_0.frameworks; [ 
    Cocoa
    MetalKit
    WebKit
  ];

  configurePhase = ''
    runHook preConfigure
    cmake -B juce-nix-build -DCMAKE_INSTALL_PREFIX=$out
    runHook postConfigure
  '';
  buildPhase = ''
    runHook preBuild
    cmake --build juce-nix-build --target install
    runHook postBuild
  '';
}

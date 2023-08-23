let
pkgs = import <nixpkgs> {};
in
pkgs.stdenv.mkDerivation {
  name = "juce";
 
  src = pkgs.fetchFromGitHub {
    owner = "juce-framework";
    repo = "juce";
    rev = "v7.0.7";
    sha256 = "0wyy2ksxp95vnh71ybj1bbmqd5ggp13x3mk37pzr99ljs9awy8ka";
  };

}


  # buildInputs = [ imlib2 xorg.libX11 ];

  # installPhase = ''
  #   runHook preInstall
  #   mkdir -p $out/bin
  #   cp icat $out/bin
  #   runHook postInstall
  # '';
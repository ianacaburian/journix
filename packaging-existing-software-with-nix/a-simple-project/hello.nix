{ lib
, stdenv
, fetchzip
}:
 
stdenv.mkDerivation {
  name = "hello";
 
  src = fetchzip {
    url = "https://ftp.gnu.org/gnu/hello/hello-2.12.1.tar.gz";
    sha256 = "1kJjhtlsAkpNB7f6tZEs+dbKd8z7KoNHyDHEJ0tmhnc=";
  };
}
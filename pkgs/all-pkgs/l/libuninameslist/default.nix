{ stdenv
, fetchurl
, lib
}:

let
  version = "20180701";
in
stdenv.mkDerivation rec {
  name = "libuninameslist-${version}";

  src = fetchurl {
    url = "https://github.com/fontforge/libuninameslist/releases/download/"
      + "${version}/libuninameslist-dist-${version}.tar.gz";
    sha256 = "8aed97d0bc872d893d8bf642a14e49958b0613136e1bfe2a415c69599c803c90";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}


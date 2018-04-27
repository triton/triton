{ stdenv
, fetchurl
, lib
}:

let
  version = "0.5.20150702";
in
stdenv.mkDerivation rec {
  name = "libspiro-${version}";

  src = fetchurl {
    url = "https://github.com/fontforge/libspiro/releases/download/"
      + "${version}/libspiro-dist-${version}.tar.gz";
    sha256 = "514d215942b860c8ee77282b14e11129ecea1992f8dfcb9ea69c0f68249f6c94";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}


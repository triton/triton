{ stdenv
, fetchurl
, lib
}:

let
  version = "6.9.5-rev1";
  version' = lib.replaceChars ["-"] ["_"] version;
in
stdenv.mkDerivation rec {
  name = "oniguruma-${version}";

  src = fetchurl {
    url = "https://github.com/kkos/oniguruma/releases/download/v${version'}/onig-${version}.tar.gz";
    sha256 = "d33c849d1672af227944878cefe0a8fcf26fc62bedba32aa517f2f63c314a99e";
  };

  meta = with stdenv.lib; {
    homepage = http://www.geocities.jp/kosako3/oniguruma/;
    description = "Regular expressions library";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
}:

let
  version = "6.2.0";
in
stdenv.mkDerivation rec {
  name = "oniguruma-${version}";

  src = fetchurl {
    url = "https://github.com/kkos/oniguruma/releases/download/v${version}/onig-${version}.tar.gz";
    sha256 = "6561637f340c6cae468aa4df45c7a4d8525fad65495b0dcef72d749aa8733a4b";
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

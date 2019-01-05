{ stdenv
, fetchurl
}:

let
  version = "6.9.1";
in
stdenv.mkDerivation rec {
  name = "oniguruma-${version}";

  src = fetchurl {
    url = "https://github.com/kkos/oniguruma/releases/download/v${version}/onig-${version}.tar.gz";
    sha256 = "c7c3feb7be45a5cc9f2dec239b4a317a422e6ffea299cf91ffab1b926633ea12";
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

{ stdenv
, fetchurl
}:

let
  version = "6.9.2";
in
stdenv.mkDerivation rec {
  name = "oniguruma-${version}";

  src = fetchurl {
    url = "https://github.com/kkos/oniguruma/releases/download/v${version}/onig-${version}.tar.gz";
    sha256 = "db7addb196ecb34e9f38d8f9c97b29a3e962c0e17ea9636127b3e3c42f24976a";
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

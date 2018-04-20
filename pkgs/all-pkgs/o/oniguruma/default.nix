{ stdenv
, fetchurl
}:

let
  version = "6.8.2";
in
stdenv.mkDerivation rec {
  name = "oniguruma-${version}";

  src = fetchurl {
    url = "https://github.com/kkos/oniguruma/releases/download/v${version}/onig-${version}.tar.gz";
    sha256 = "adeada5f6b54c2a6f58ff021831a01b18a62b55ea9935e972e36ebb19e7c4903";
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

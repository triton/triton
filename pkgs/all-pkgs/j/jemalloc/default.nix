{ stdenv
, fetchurl
}:

let
  version = "4.4.0";
in
stdenv.mkDerivation rec {
  name = "jemalloc-${version}";

  src = fetchurl {
    url = "https://github.com/jemalloc/jemalloc/releases/download/${version}/"
      + "${name}.tar.bz2";
    sha256 = "a7aea63e9718d2f1adf81d87e3df3cb1b58deb86fc77bad5d702c4c59687b033";
  };

  dontDisableStatic = true;

  meta = with stdenv.lib; {
    homepage = http://www.canonware.com/jemalloc/index.html;
    description = "General purpose malloc(3) implementation";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

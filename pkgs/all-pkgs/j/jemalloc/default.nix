{ stdenv
, fetchurl
}:

let
  version = "4.3.0";
in
stdenv.mkDerivation rec {
  name = "jemalloc-${version}";

  src = fetchurl {
    url = "https://github.com/jemalloc/jemalloc/releases/download/${version}/"
      + "${name}.tar.bz2";
    sha256 = "2142d4093708b2f988f60ed5fd8d869447cd9f5354933e596400c0a69bfef5e0";
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

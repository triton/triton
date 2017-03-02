{ stdenv
, fetchurl
}:

let
  version = "4.5.0";
in
stdenv.mkDerivation rec {
  name = "jemalloc-${version}";

  src = fetchurl {
    url = "https://github.com/jemalloc/jemalloc/releases/download/${version}/"
      + "${name}.tar.bz2";
    sha256 = "9409d85664b4f135b77518b0b118c549009dc10f6cba14557d170476611f6780";
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

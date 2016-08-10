{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "nasm-${version}";
  version = "2.12.01";

  src = fetchurl {
    url = "http://www.nasm.us/pub/nasm/releasebuilds/${version}/" +
          "${name}.tar.bz2";
    sha256 = "f8bebee8107a42f6661526cf9e0bd92fcd33ff0df01ea05093f7650ec60d902b";
  };

  meta = with stdenv.lib; {
    description = "An assembler for x86 and x86_64 instruction sets";
    homepage = http://www.nasm.us/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

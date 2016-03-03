{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "nasm-${version}";
  version = "2.12";

  src = fetchurl {
    url = "http://www.nasm.us/pub/nasm/releasebuilds/${version}/" +
          "${name}.tar.bz2";
    sha256 = "07l3cx88lnr57xi2q46xzh5cwqyswimaqgnms69h0m41614hb80f";
  };

  meta = with stdenv.lib; {
    description = "An assembler for x86 and x86_64 instruction sets";
    homepage = http://www.nasm.us/;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

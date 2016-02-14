{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "nasm-${version}";
  version = "2.11.08";

  src = fetchurl {
    url = "http://www.nasm.us/pub/nasm/releasebuilds/${version}/" +
          "${name}.tar.bz2";
    sha256 = "0ialkla6i63j8fpv840jy7k5mdf2wbqr98bvbcq0dp0b38ls18wx";
  };

  meta = with stdenv.lib; {
    description = "An assembler for x86 and x86_64 instruction sets";
    homepage = http://www.nasm.us/;
    license = with licenses; [
      bsd
      bsdOrginal
    ];
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

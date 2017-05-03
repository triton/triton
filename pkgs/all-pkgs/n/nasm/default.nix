{ stdenv
, fetchurl
}:

let
  version = "2.13.01";
in
stdenv.mkDerivation rec {
  name = "nasm-${version}";

  src = fetchurl {
    url = "http://www.nasm.us/pub/nasm/releasebuilds/${version}/"
      + "${name}.tar.xz";
    multihash = "QmUadfDT8z2wGBF4vRc41YKDji2BoSt1iFF5ft3mHyTDrj";
    sha256 = "aa0213008f0433ecbe07bb628506a5c4be8079be20fc3532a5031fd639db9a5e";
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

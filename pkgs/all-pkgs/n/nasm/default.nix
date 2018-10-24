{ stdenv
, fetchurl
, lib
}:

let
  version = "2.13.03";
in
stdenv.mkDerivation rec {
  name = "nasm-${version}";

  src = fetchurl {
    url = "https://www.nasm.us/pub/nasm/releasebuilds/${version}/"
      + "${name}.tar.xz";
    multihash = "QmaYeHp1JoEH5kGKr8Vo6C3aZpRTvMdA6JiSvGFmUx9h6e";
    sha256 = "812ecfb0dcbc5bd409aaa8f61c7de94c5b8752a7b00c632883d15b2ed6452573";
  };

  # Needed with 2.13.03 and gcc8
  NIX_CFLAGS_COMPILE = "-Wno-error=attributes";

  meta = with lib; {
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

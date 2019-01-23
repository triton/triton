{ stdenv
, fetchurl
, lib
}:

let
  version = "2.14.02";
in
stdenv.mkDerivation rec {
  name = "nasm-${version}";

  src = fetchurl {
    url = "https://www.nasm.us/pub/nasm/releasebuilds/${version}/"
      + "${name}.tar.xz";
    multihash = "QmSKbe3syZ1UE3q4GsY1iJfqUQbY4igxDTJ5RPfz8uAumS";
    sha256 = "e24ade3e928f7253aa8c14aa44726d1edf3f98643f87c9d72ec1df44b26be8f5";
  };

  configureFlags = [
    "--enable-lto"
  ];

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

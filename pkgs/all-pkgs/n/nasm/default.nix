{ stdenv
, fetchurl
, lib
}:

let
  version = "2.14";
in
stdenv.mkDerivation rec {
  name = "nasm-${version}";

  src = fetchurl {
    url = "https://www.nasm.us/pub/nasm/releasebuilds/${version}/"
      + "${name}.tar.xz";
    multihash = "QmaZG2ZVmqxcUY38z2RYGRBzfyKi88VdpFMAYDHZb5weHy";
    sha256 = "97c615dbf02ef80e4e2b6c385f7e28368d51efc214daa98e600ca4572500eec0";
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

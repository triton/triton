{ stdenv
, fetchurl
, lib
}:

let
  version = "2.13.02";
in
stdenv.mkDerivation rec {
  name = "nasm-${version}";

  src = fetchurl {
    url = "http://www.nasm.us/pub/nasm/releasebuilds/${version}/"
      + "${name}.tar.xz";
    multihash = "QmNpFFHbDa6CDtLhq7QTzjq9oJBDV5dJVj5boDmHA2PeYi";
    sha256 = "8ac3235f49a6838ff7a8d7ef7c19a4430d0deecc0c2d3e3e237b5e9f53291757";
  };

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

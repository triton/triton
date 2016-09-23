{ stdenv
, fetchurl
}:

let
  version = "2.12.02";
in
stdenv.mkDerivation rec {
  name = "nasm-${version}";

  src = fetchurl {
    url = "http://www.nasm.us/pub/nasm/releasebuilds/${version}/"
      + "${name}.tar.bz2";
    multihash = "QmVcsibVf9LePwrMKfmMrs7VPRApq7V56QkPohGsgEg3zd";
    sha256 = "00b0891c678c065446ca59bcee64719d0096d54d6886e6e472aeee2e170ae324";
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

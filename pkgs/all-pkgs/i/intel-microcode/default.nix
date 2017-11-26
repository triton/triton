{ stdenv
, fetchurl
, libarchive
}:

let
  version = "2017-11-17";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
  id = "27337";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${version}";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/${id}/eng/microcode-${version'}.tgz";
    multihash = "QmTmhQvsG9HLLvGjCpiEEp4MR1Um6x9W9cXRjMFScdAdyz";
    hashOutput = false;
    sha256 = "93bd1da9fa58ece0016702e657f708b7e496e56da637a3fe9a6d21f1d6f524dc";
  };

  nativeBuildInputs = [
    libarchive
  ];

  srcRoot = ".";

  preUnpack = ''
    mkdir src
    cd src
  '';

  buildPhase = ''
    gcc -O2 -Wall -o intel-microcode2ucode ${./intel-microcode2ucode.c}
    ./intel-microcode2ucode microcode.dat
  '';

  installPhase = ''
    install -D -m755 -v 'microcode.bin' 'kernel/x86/microcode/GenuineIntel.bin'
    mkdir -pv $out
    echo 'kernel/x86/microcode/GenuineIntel.bin' | \
      bsdcpio -o -H newc -R 0:0 > "$out/intel-ucode.img"
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      md5Confirm = "b294245d1f7f6c20f01edba53185f258";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Microcode for Intel processors";
    homepage = http://www.intel.com/;
    license = licenses.unfreeRedistributableFirmware;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

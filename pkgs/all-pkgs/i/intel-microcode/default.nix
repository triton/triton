{ stdenv
, fetchurl
, libarchive
}:

let
  version = "2018-01-08";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
  id = "27431";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${version}";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/${id}/eng/microcode-${version'}.tgz";
    multihash = "QmaQ8wecxjDxw974yCNK3NHj3dkMxdP12dRFX8GCUQaJtQ";
    hashOutput = false;
    sha256 = "063f1aa3a546cb49323a5e0b516894e4b040007107b8c8ff017aca8a86204130";
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
      md5Confirm = "871df55f0ab010ee384dabfc424f2c12";
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

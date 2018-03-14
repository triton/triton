{ stdenv
, fetchurl
, libarchive
}:

let
  version = "2018-03-12";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
  id = "27591";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${version}";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/${id}/eng/microcode-${version'}.tgz";
    multihash = "QmaracYm7xYdziytD8M4dcxVpeX6ZXBBrkZW5zCrS15d1R";
    hashOutput = false;
    sha256 = "0b381face2df1b0a829dc4fa8fa93f47f39e11b1c9c22ebd44f8614657c1e779";
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
      md5Confirm = "be315cd99a7ca392a2f917ceacbe14f2";
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

{ stdenv
, fetchurl
, libarchive
}:

let
  version = "2017-05-11";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
  id = "26798";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${version}";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/${id}/eng/microcode-${version'}.tgz";
    multihash = "QmUcrJ45CsJ83YoyMgGTE9g54H2yzkHUUArJDVnvknczDP";
    hashOutput = false;
    sha256 = "2f77fd2d87403b754d01a66c78a36a8b8ffc16dc3c50fb7aa2c4cd4da7f681a3";
  };

  nativeBuildInputs = [
    libarchive
  ];

  sourceRoot = ".";

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
      md5Confirm = "167e6e1ff234567291f067f48e11d740";
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

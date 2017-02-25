{ stdenv
, fetchurl
, libarchive
}:

let
  version = "2016-11-04";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
  id = "26400";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${version}";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/${id}/eng/microcode-${version'}.tgz";
    md5Confirm = "6720d5c2673d79ca8e4ac8e66d8597bf";
    sha256 = "70154ca62ff9b3da6291dfdecc90daaeb399d7290c0d308d719df16dff5ee3d1";
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

{ stdenv
, fetchurl
, libarchive
}:

let
  version = "20160607";
  id = "26083";
in

stdenv.mkDerivation rec {
  name = "intel-microcode-${version}";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/${id}/eng/microcode-${version}.tgz";
    sha256 = "db821eb47af2caa39613caee0eb89a9584b2ebc4a9ab1b9624fe778f9a41fa7d";
  };

  nativeBuildInputs = [
    libarchive
  ];

  sourceRoot = ".";

  postPatch =
    /* Some Intel Skylake CPUs with signature 0x406e3 have issues updating
       microcode. Remove for now...
       https://bugs.archlinux.org/task/49806 */ ''
      sed -i microcode.dat \
        -e "/mc0406e3/,/mc/d"
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

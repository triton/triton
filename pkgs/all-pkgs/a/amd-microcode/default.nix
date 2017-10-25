{ stdenv
, fetchurl

, libarchive
, linux-firmware
}:

stdenv.mkDerivation rec {
  name = "amd-microcode-${linux-firmware.version}";

  src = linux-firmware;

  srcRoot = ".";

  preUnpack = ''
    mkdir src
    cd src
  '';

  nativeBuildInputs = [
    libarchive
  ];

  buildPhase = ''
    mkdir -p kernel/x86/microcode
    find ${linux-firmware}/lib/firmware/amd-ucode -name \*.bin \
      -exec sh -c 'cat {} >> kernel/x86/microcode/AuthenticAMD.bin' \;
  '';

  installPhase = ''
    mkdir -p $out
    echo kernel/x86/microcode/AuthenticAMD.bin | bsdcpio -o -H newc -R 0:0 > $out/amd-ucode.img
  '';

  meta = with stdenv.lib; {
    description = "AMD Processor microcode patch";
    homepage = http://www.amd64.org/support/microcode.html;
    license = licenses.unfreeRedistributableFirmware;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

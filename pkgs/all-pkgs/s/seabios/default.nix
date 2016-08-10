{ stdenv
, fetchurl
, iasl
, python
}:

stdenv.mkDerivation rec {
  name = "seabios-1.9.3";

  src = fetchurl {
    url = "https://code.coreboot.org/p/seabios/downloads/get/${name}.tar.gz";
    sha256 = "1ae85dc049cdee1ca953612e9ab4cec3941a4a4e744b7036624c308781b0678d";
  };

  nativeBuildInputs = [
    iasl
    python
  ];

  configurePhase = ''
    # build SeaBIOS for CSM
    cat > .config << EOF
    CONFIG_CSM=y
    CONFIG_QEMU_HARDWARE=y
    CONFIG_PERMIT_UNALIGNED_PCIROM=y
    EOF

    make olddefconfig
  '';

  installPhase = ''
    mkdir $out
    cp out/Csm16.bin $out/Csm16.bin
  '';

  meta = with stdenv.lib; {
    description = "Open source implementation of a 16bit X86 BIOS";
    homepage = http://www.seabios.org;
    broken = true;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}


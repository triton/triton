{ stdenv
, fetchurl
, iasl
, python
}:

stdenv.mkDerivation rec {
  name = "seabios-1.10.1";

  src = fetchurl {
    url = "https://code.coreboot.org/p/seabios/downloads/get/${name}.tar.gz";
    multihash = "QmWGwG4ANLwEAKZfJUoL6VenJth2emVPKEAsi2g1N6kbLE";
    sha256 = "5063ddbac61ec4e61a12daa83931c37e5629b1c18502f7c00ed4e696c2a1d2cb";
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
    EOF

    make olddefconfig
    cat .config
  '';

  installPhase = ''
    mkdir -p $out/share/seabios
    cp out/Csm16.bin $out/share/seabios/Csm16.bin
  '';

  # We don't need any security / optimization features for a bios image
  optFlags = false;
  pie = false;
  fpic = false;
  noStrictOverflow = false;
  fortifySource = false;
  stackProtector = false;
  optimize = false;

  meta = with stdenv.lib; {
    description = "Open source implementation of a 16bit X86 BIOS";
    homepage = http://www.seabios.org;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}


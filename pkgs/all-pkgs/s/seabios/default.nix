{ stdenv
, fetchurl
, iasl
, python

, type
}:

assert type == "qemu";

stdenv.mkDerivation rec {
  name = "seabios-1.11.0";

  src = fetchurl {
    url = "https://code.coreboot.org/p/seabios/downloads/get/${name}.tar.gz";
    multihash = "QmYBzjZ94JDD3jjxtFx2zMEsbpDYMkQkruDVpShScjmF51";
    sha256 = "622b432ebb8a3b0b13b8accd6d4a196a7eb3af11f243815e5f7d75d9ceb99bf7";
  };

  nativeBuildInputs = [
    iasl
    python
  ];

  configurePhase = ''
    cat > .config << EOF
    CONFIG_QEMU=y
    CONFIG_VGA_CIRRUS=y
    CONFIG_DEBUG_LEVEL=0
    EOF

    make olddefconfig
    cat .config
  '';

  installPhase = ''
    mkdir -p $out/share/seabios
    cp out/bios.bin $out/share/seabios
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


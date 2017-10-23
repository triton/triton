{ stdenv
, fetchurl
, iasl
, python

, type
}:

assert type == "qemu";

stdenv.mkDerivation rec {
  name = "seabios-1.10.3";

  src = fetchurl {
    url = "https://code.coreboot.org/p/seabios/downloads/get/${name}.tar.gz";
    multihash = "QmfN3eGMvRWDPsYUeDMAuSrs2vuykBv7Bm7gv76bJvqoNM";
    sha256 = "273e157f02b68acb110a5004d8f3045b5a1a5ae7e5dcca7557b57531bc3b44e8";
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


{ stdenv
, fetchurl
, iasl
, python

, type
}:

assert type == "qemu";

stdenv.mkDerivation rec {
  name = "seabios-1.10.2";

  src = fetchurl {
    url = "https://code.coreboot.org/p/seabios/downloads/get/${name}.tar.gz";
    multihash = "QmZeo4sGnCbd5ZZA8EvKLNrnrQUuU5rUN8ELQrvaGL2rbb";
    sha256 = "89c70b70fa7ab179694efb95c2c89d4f50a39381321cbed5d8302cb9b25e953d";
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


{ stdenv
, fetchurl
, iasl
, python

, type
}:

assert type == "qemu";

stdenv.mkDerivation rec {
  name = "seabios-1.12.0";

  src = fetchurl {
    url = "https://www.seabios.org/downloads/${name}.tar.gz";
    multihash = "QmeqJnikiz38Do71oMiMVqg77kpSHNwer3sYTD3e1utEnZ";
    sha256 = "df17b8e565e75c27897ceb82af853b7c568eba7911f3bd173f8a68c1b4bda74b";
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = { };
    };
  };

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


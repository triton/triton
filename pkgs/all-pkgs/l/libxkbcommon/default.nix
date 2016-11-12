{ stdenv
, bison
, fetchurl
, flex

, xorg
}:

stdenv.mkDerivation rec {
  name = "libxkbcommon-0.7.0";

  src = fetchurl {
    url = "http://xkbcommon.org/download/${name}.tar.xz";
    hashOutput = false;
    sha256 = "09351592312d67b438655f54da5b67853026662c4a57e6be4d225f04a9989798";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    xorg.libxcb
    xorg.xkeyboardconfig
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-docs"
    "--enable-x11"
    "--with-xkb-config-root=${xorg.xkeyboardconfig}/etc/X11/xkb"
  ];

  meta = with stdenv.lib; {
    description = "A library to handle keyboard descriptions";
    homepage = http://xkbcommon.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}


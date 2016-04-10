{ stdenv
, bison
, fetchurl
, flex

, xorg
}:

stdenv.mkDerivation rec {
  name = "libxkbcommon-0.6.1";

  src = fetchurl {
    url = "http://xkbcommon.org/download/${name}.tar.xz";
    sha1Confirm = "85175bd3baa2cb6207beb5ac980568b70e1a6a3d";
    sha256 = "5b0887b080b42169096a61106661f8d35bae783f8b6c58f97ebcd3af83ea8760";
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


{ stdenv
, bison
, fetchurl
, flex

, xorg
}:

stdenv.mkDerivation rec {
  name = "libxkbcommon-0.6.0";

  src = fetchurl {
    url = "http://xkbcommon.org/download/${name}.tar.xz";
    sha1Confirm = "b9d9e0a02c9bc439a387dba27ff8115c1f1afb56";
    sha256 = "69235ec3a13194dea9555d7994bc4548b3ee20070e05a135af5372a958149ef0";
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


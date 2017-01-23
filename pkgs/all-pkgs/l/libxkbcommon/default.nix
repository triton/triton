{ stdenv
, bison
, fetchurl
, flex

, xorg
}:

stdenv.mkDerivation rec {
  name = "libxkbcommon-0.7.1";

  src = fetchurl {
    url = "https://xkbcommon.org/download/${name}.tar.xz";
    multihash = "QmV9fD6Anzj54NQfwAnHWHGwH1a63sPR1xzQwnuDz3oDwN";
    hashOutput = false;
    sha256 = "ba59305d2e19e47c27ea065c2e0df96ebac6a3c6e97e28ae5620073b6084e68b";
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
    homepage = https://xkbcommon.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}


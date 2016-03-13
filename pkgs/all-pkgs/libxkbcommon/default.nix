{ stdenv
, bison
, fetchurl
, flex

, xorg
}:

stdenv.mkDerivation rec {
  name = "libxkbcommon-0.5.0";

  src = fetchurl {
    url = "http://xkbcommon.org/download/${name}.tar.xz";
    sha1Confirm = "7127993bfb69e13cdff25fb8b3c8f26ce6be5bfa";
    sha256 = "176ii5dn2wh74q48sd8ac37ljlvgvp5f506glr96z6ibfhj7igch";
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
    "--with-xkb-config-root=${xorg.xkeyboardconfig}/etc/X11/xkb"
  ];

  meta = with stdenv.lib; {
    description = "A library to handle keyboard descriptions";
    homepage = http://xkbcommon.org;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}


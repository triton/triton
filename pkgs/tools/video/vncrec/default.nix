{ stdenv, fetchurl, xorg
}:

stdenv.mkDerivation rec {
  name = "vncrec-0.2"; # version taken from Arch AUR

  src = fetchurl {
    url = "http://ronja.twibright.com/utils/vncrec-twibright.tgz";
    sha256 = "1yp6r55fqpdhc8cgrgh9i0mzxmkls16pgf8vfcpng1axr7cigyhc";
  };

  buildInputs = [
    xorg.libX11 xorg.xproto xorg.imake xorg.gccmakedep xorg.libXt xorg.libXmu xorg.libXaw
    xorg.libXext xorg.xextproto xorg.libSM xorg.libICE xorg.libXpm xorg.libXp
  ];

  buildPhase = ''xmkmf && make World'';

  installPhase = ''
    make DESTDIR=$out BINDIR=/bin MANDIR=/share/man/man1 install install.man
  '';

  meta = {
    description = "VNC recorder";
    homepage = http://ronja.twibright.com/utils/vncrec/;
  };
}

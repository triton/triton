{ stdenv
, autoconf
, automake
, bison
, fetchurl
, flex
, libtool
, texinfo

# Optional Dependencies
, ncurses
}:

stdenv.mkDerivation rec {
  name = "gpm-1.20.7";

  src = fetchurl {
    url = "http://www.nico.schottelius.org/software/gpm/archives/${name}.tar.bz2";
    sha256 = "13d426a8h403ckpc8zyf7s2p5rql0lqbg2bv0454x0pvgbfbf4gh";
  };

  nativeBuildInputs = [
    autoconf
    automake
    bison
    flex
    libtool
    texinfo
  ];

  buildInputs = [
    ncurses
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    (if ncurses == null then "--without-curses" else "--with-curses")
  ];

  # Provide libgpm.so for compatability
  postInstall = ''
    ln -sv libgpm.so.2 $out/lib/libgpm.so
  '';

  meta = with stdenv.lib; {
    homepage = http://www.nico.schottelius.org/software/gpm/;
    description = "A daemon that provides mouse support on the Linux console";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

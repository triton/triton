{ stdenv
, fetchurl

, libselinux
, ncurses
}:

stdenv.mkDerivation rec {
  name = "psmisc-23.1";

  src = fetchurl {
    url = "mirror://sourceforge/psmisc/psmisc/${name}.tar.xz";
    sha256 = "2e84d474cf75dfbe3ecdacfb797bbfab71a35c7c2639d1b9f6d5f18b2149ba30";
  };

  buildInputs = [
    libselinux
    ncurses
  ];

  configureFlags = [
    "--enable-selinux"
  ];

  meta = with stdenv.lib; {
    description = "A set of tools that use the proc filesystem";
    homepage = http://psmisc.sourceforge.net/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

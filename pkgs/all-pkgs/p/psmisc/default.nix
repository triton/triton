{ stdenv
, fetchurl

, libselinux
, ncurses
}:

stdenv.mkDerivation rec {
  name = "psmisc-23.3";

  src = fetchurl {
    url = "mirror://sourceforge/psmisc/psmisc/${name}.tar.xz";
    hashOutput = false;
    sha256 = "41750e1a5abf7ed2647b094f58127c73dbce6876f77ba4e0a7e0995ae5c7279a";
  };

  buildInputs = [
    libselinux
    ncurses
  ];

  configureFlags = [
    "--enable-selinux"
  ];

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

{ stdenv
, fetchurl

, libselinux
, ncurses
}:

stdenv.mkDerivation rec {
  name = "psmisc-23.2";

  src = fetchurl {
    url = "mirror://sourceforge/psmisc/psmisc/${name}.tar.xz";
    hashOutput = false;
    sha256 = "4b7cbffdc9373474da49b85dc3457ae511c43dc7fa7d94513fe06f89dcb87880";
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

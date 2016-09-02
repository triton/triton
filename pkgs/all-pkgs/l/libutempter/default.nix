{ stdenv
, fetchurl

, glib
}:

let
  version = "1.1.6";
in
stdenv.mkDerivation rec {
  name = "libutempter-${version}";

  src = fetchurl {
    urls = [
      "mirror://gentoo/distfiles/${name}.tar.bz2"
      "ftp://ftp.altlinux.org/pub/people/ldv/utempter/${name}.tar.bz2"
    ];
    hashOutput = false;
    sha256 = "15y3xbgznjxnfmix4xg3bwmqdvghdw7slbhazb0ybmyf65gmd65q";
  };

  buildInputs = [
    glib
  ];

  preInstall = ''
    installFlagsArray+=(
      "libdir=$out/lib"
      "libexecdir=$out/lib"
      "includedir=$out/include"
      "mandir=$out/share/man"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "8839 24C0 2E6D 60FA D309  B0C9 D97A 868B F7DD BB3A";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Interface for terminal emulators such as screen and xterm to record user sessions to utmp and wtmp files";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

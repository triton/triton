{ stdenv
, fetchurl

, ncurses
}:

let
  version = "3.3.15";
in
stdenv.mkDerivation rec {
  name = "procps-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/procps-ng/Production/procps-ng-${version}.tar.xz";
    hashOutput = false;
    sha256 = "10bd744ffcb3de2d591d2f6acf1a54a7ba070fdcc432a855931a5057149f0465";
  };

  buildInputs = [
    ncurses
  ];

  makeFlags = [
    "usrbin_execdir=$(out)/bin"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "5D2F B320 B825 D939 04D2  0519 3938 F96B DF50 FEA5";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://sourceforge.net/projects/procps-ng/;
    description = "Utilities that give information about processes using the /proc filesystem";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

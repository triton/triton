{ stdenv
, autoreconfHook
, fetchurl
}:

let
  version = "1.1.24+nmu5";
in
stdenv.mkDerivation rec {
  name = "libpaper-${version}";

  src = fetchurl {
    url = "mirror://debian/pool/main/libp/libpaper/libpaper_${version}.tar.gz";
    sha256 = "e29deda4cd7350189c71af0925cbf4a4473f9841d1419a922e1e8ff1954db1f2";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with stdenv.lib; {
    description = "Library for handling paper characteristics";
    homepage = "http://packages.debian.org/unstable/source/libpaper";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

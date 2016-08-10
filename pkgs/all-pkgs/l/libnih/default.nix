{ stdenv
, fetchurl
, gettext

, dbus
, expat
}:

let
  version = "1.0.3";
in

stdenv.mkDerivation rec {
  name = "libnih-${version}";
  
  src = fetchurl {
    url = "http://code.launchpad.net/libnih/1.0/${version}/+download/libnih-${version}.tar.gz";
    sha256 = "01glc6y7z1g726zwpvp2zm79pyb37ki729jkh45akh35fpgp4xc9";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    dbus
    expat
  ];

  meta = with stdenv.lib; {
    description = "A small library for C application development";
    homepage = https://launchpad.net/libnih;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

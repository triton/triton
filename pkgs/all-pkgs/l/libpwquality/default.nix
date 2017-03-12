{ stdenv
, fetchurl
, lib

, cracklib
, python
}:

stdenv.mkDerivation rec {
  name = "libpwquality-1.3.0";

  src = fetchurl {
    url = "https://github.com/libpwquality/libpwquality/releases/download/"
      + "${name}/${name}.tar.bz2";
    sha256 = "74d2ea90e103323c1f2d6a6cc9617cdae6877573eddb31aaf31a40f354cc2d2a";
  };

  buildInputs = [
    cracklib
    python
  ];

  meta = with lib; {
    description = "Password quality checking library";
    homepage = https://github.com/libpwquality/libpwquality;
    license = with licenses; [
      bsd
      gpl2
    ];
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}

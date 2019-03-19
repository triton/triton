{ stdenv
, fetchurl
, lib

, cracklib
, python
}:

stdenv.mkDerivation rec {
  name = "libpwquality-1.4.0";

  src = fetchurl {
    url = "https://github.com/libpwquality/libpwquality/releases/download/"
      + "${name}/${name}.tar.bz2";
    sha256 = "1de6ff046cf2172d265a2cb6f8da439d894f3e4e8157b056c515515232fade6b";
  };

  buildInputs = [
    cracklib
    python
  ];

  meta = with lib; {
    description = "Password quality checking library";
    homepage = https://github.com/libpwquality/libpwquality;
    license = with licenses; [
      bsd3
      gpl2
    ];
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}

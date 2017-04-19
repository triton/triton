{ stdenv
, fetchurl
, python

, glib
, libgudev
, libmbim
}:

stdenv.mkDerivation rec {
  name = "libqmi-1.18.0";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libqmi/${name}.tar.xz";
    multihash = "QmZZs9nTRFqkwNHcjxU2XJuWJAF9okzF9PxBxEcnRSU93y";
    sha256 = "a0a42c55935e75a630208e2f70840bd4407f56fe1c5258f5b0f6c0aaedf88cec";
  };

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    glib
    libgudev
    libmbim
  ];

  preBuild = ''
    patchShebangs .
  '';

  meta = with stdenv.lib; {
    homepage = http://www.freedesktop.org/wiki/Software/libqmi/;
    description = "Modem protocol helper library";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

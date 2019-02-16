{ stdenv
, fetchurl
, lib
, python

, glib
, libgudev
, libmbim
}:

stdenv.mkDerivation rec {
  name = "libqmi-1.22.0";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libqmi/${name}.tar.xz";
    multihash = "QmaRus8rwk88FDfmGSotiG3Mh9utSa5da3A95xaD7XZ1LL";
    sha256 = "IcGYtIHxYXu37bGWDYI1ad4+OLJp2/UTrxtWBIyvqhc=";
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

  meta = with lib; {
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

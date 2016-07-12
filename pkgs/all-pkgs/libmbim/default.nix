{ stdenv
, fetchurl
, python

, glib
, libgudev
}:

stdenv.mkDerivation rec {
  name = "libmbim-1.14.0";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libmbim/${name}.tar.xz";
    sha256 = "ca8d52a95a18cbabae8f15f83f1572316e888b6504f946e6645d24405127ab5b";
  };

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    glib
    libgudev
  ];

  postPatch = ''
    patchShebangs .
  '';

  meta = with stdenv.lib; {
    homepage = http://www.freedesktop.org/software/libmbim/;
    description = "Library for WWAN modems & devices which use the Mobile Broadband Interface Model (MBIM) protocol";
    license = with licenses; [
      gpl2Plus
      lgpl21Plus
    ];
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

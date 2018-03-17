{ stdenv
, fetchurl
, lib
, python2

, glib
, libgudev
}:

stdenv.mkDerivation rec {
  name = "libmbim-1.16.0";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libmbim/${name}.tar.xz";
    multihash = "QmfQVi9ZwXUv2aY2UGw1zUA5gj9HR96KWJCVyRqbJn8wSU";
    sha256 = "c8ca50beeddd4b43309df5b698917268303bf176cea58fe4fe53d5bf0e93fac2";
  };

  nativeBuildInputs = [
    python2
  ];

  buildInputs = [
    glib
    libgudev
  ];

  postPatch = ''
    patchShebangs .
  '';

  meta = with lib; {
    description = "Library for WWAN modems & devices using the MBIM protocol";
    homepage = http://www.freedesktop.org/software/libmbim/;
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

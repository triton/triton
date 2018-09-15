{ stdenv
, fetchurl

, glib
, nss
, pcsc-lite_lib
}:

stdenv.mkDerivation rec {
  name = "libcacard-2.6.1";

  src = fetchurl {
    url = "https://www.spice-space.org/download/libcacard/${name}.tar.xz";
    multihash = "QmSHukp2V22NVpxs5y3AgJVgBkHg4Mp5DxpxmYDEi65eh9";
    sha256 = "6276c6a2bd018bf14f1b97260fff093b4a2325a9177be4fc6be7c1a9e204def0";
  };

  buildInputs = [
    glib
    nss
    pcsc-lite_lib
  ];

  meta = with stdenv.lib; {
    homepage = http://www.spice-space.org/download/libcacard/;
    description = "Spice smart card library";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

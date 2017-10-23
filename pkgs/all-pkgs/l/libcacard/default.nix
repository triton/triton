{ stdenv
, fetchurl

, glib
, nss
, pcsc-lite_lib
}:

stdenv.mkDerivation rec {
  name = "libcacard-2.5.3";

  src = fetchurl {
    url = "https://www.spice-space.org/download/libcacard/${name}.tar.xz";
    multihash = "QmS1N1L2FcmK4aZmr2bBoDe6rxbrXMDc2iwDHWQngboC1k";
    sha256 = "243ff03c563a95faed497db7f524fcb34ccd6f388d1175ecf31c371a3188963b";
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

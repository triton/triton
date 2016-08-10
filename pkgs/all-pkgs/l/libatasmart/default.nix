{ stdenv
, fetchurl

, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "libatasmart-0.19";

  src = fetchurl {
    url = "http://0pointer.de/public/${name}.tar.xz";
    multihash = "QmWhyzexC1LvxsUD8qoxP8X7y91rNtCvgY7GEGWioXLvvs";
    sha256 = "138gvgdwk6h4ljrjsr09pxk1nrki4b155hqdzyr8mlk3bwsfmw31";
  };

  buildInputs = [
    systemd_lib
  ];

  meta = with stdenv.lib; {
    homepage = http://0pointer.de/public/;
    description = "Library for querying ATA SMART status";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

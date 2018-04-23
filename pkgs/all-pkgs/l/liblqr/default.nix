{ stdenv
, fetchurl
, lib

, glib
}:

stdenv.mkDerivation rec {
  name = "liblqr-1-0.4.2";

  src = fetchurl {
    url = "http://liblqr.wdfiles.com/local--files/en:download-page/${name}.tar.bz2";
    multihash = "QmZR1ZbsZkS8TDBDdfusEd7B7cms8AT2GeZjDNWgesgMXK";
    sha256 = "0dzikxzjz5zmy3vnydh90aqk23q0qm8ykx6plz6p4z90zlp84fhp";
  };

  buildInputs = [
    glib
  ];

  meta = with lib; {
    homepage = http://liblqr.wikidot.com;
    description = "Seam-carving C/C++ library called Liquid Rescaling";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

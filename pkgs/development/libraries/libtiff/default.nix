{ stdenv, fetchTritonPatch, fetchurl, pkgconfig, zlib, libjpeg, xz }:

let
  version = "4.0.6";
in
stdenv.mkDerivation rec {
  name = "libtiff-${version}";

  src = fetchurl {
    urls = [
      "ftp://ftp.remotesensing.org/pub/libtiff/tiff-${version}.tar.gz"
      "http://download.osgeo.org/libtiff/tiff-${version}.tar.gz"
    ];
    multihash = "QmbKMJu46dA4CjcZ4Y85unK11XFhFrkDrm9gsCKkk8fEBQ";
    sha256 = "4d57a50907b510e3049a4bba0d7888930fdfc16ce49f1bf693e5b6247370d68c";
  };

  patches = [
    (fetchTritonPatch {
      rev = "7dfe464875284d5c13b6e8118db6a8846cbb6fc6";
      file = "l/libtiff/01-CVE-2015-8665_and_CVE-2015-8683.patch";
      sha256 = "dfe75179c9d934aa5fb0a962cdde0baf5e121e43e307d053590138bdd6c53162";
    })
    (fetchTritonPatch {
      rev = "7dfe464875284d5c13b6e8118db6a8846cbb6fc6";
      file = "l/libtiff/02-fix_potential_out-of-bound_writes_in_decode_functions.patch";
      sha256 = "7baad5e61b4207d04311806daba80dafeabbbd9e86379849d2220a30f82900de";
    })
    (fetchTritonPatch {
      rev = "7dfe464875284d5c13b6e8118db6a8846cbb6fc6";
      file = "l/libtiff/03-fix_potential_out-of-bound_write_in_NeXTDecode.patch";
      sha256 = "863dda301920447473d0954fd76e4b5f6b7beaafdc9e271427f1fbdd9e7812da";
    })
    (fetchTritonPatch {
      rev = "7dfe464875284d5c13b6e8118db6a8846cbb6fc6";
      file = "l/libtiff/04-CVE-2016-5314_CVE-2016-5316_CVE-2016-5320_CVE-2016-5875.patch";
      sha256 = "c3ce5c7b7ba9c5d2bf5dfd276c25face038cd585abd4edc591896dc6d3f48758";
    })
    (fetchTritonPatch {
      rev = "7dfe464875284d5c13b6e8118db6a8846cbb6fc6";
      file = "l/libtiff/05-CVE-2016-6223.patch";
      sha256 = "593c53a3722df6dd018bc0a5222a43cc7ca1418592fa77af6c4c9b9968840065";
    })
    (fetchTritonPatch {
      rev = "7dfe464875284d5c13b6e8118db6a8846cbb6fc6";
      file = "l/libtiff/06-CVE-2016-5321.patch";
      sha256 = "0f1bfc610510191123c047dba7aeec638f5cc04eaa2e4b22aa8a998d69f54ca9";
    })
    (fetchTritonPatch {
      rev = "7dfe464875284d5c13b6e8118db6a8846cbb6fc6";
      file = "l/libtiff/07-CVE-2016-5323.patch";
      sha256 = "90d1f5e42f2ad2b0f88ad0ffe70f109b2edf2f4a8906c6dc90e1a8ee848725f7";
    })
  ];

  outputs = [ "out" "doc" "man" ];

  nativeBuildInputs = [ pkgconfig ];

  propagatedBuildInputs = [ zlib libjpeg xz ]; #TODO: opengl support (bogus configure detection)

  enableParallelBuilding = true;

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Library and utilities for working with the TIFF image file format";
    homepage = http://www.remotesensing.org/libtiff/;
    license = licenses.libtiff;
    platforms = platforms.all;
  };
}

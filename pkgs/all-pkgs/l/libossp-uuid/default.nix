{ stdenv
, fetchurl
}:

let
  version = "1.6.2";
in
stdenv.mkDerivation rec {
  name = "libossp-uuid-${version}";

  src = fetchurl {
    urls = [
      "ftp://ftp.ossp.org/pkg/lib/uuid/uuid-${version}.tar.gz"
      "http://www.mirrorservice.org/sites/ftp.ossp.org/pkg/lib/uuid/uuid-${version}.tar.gz"
    ];
    multihash = "QmWwswUwjQnnLENKcnE44VzBBg9ngMutjbrpgpfE5NUMfS";
    sha256= "11a615225baa5f8bb686824423f50e4427acd3f70d394765bdff32801f0fd5b0";
  };

  configureFlags = [
    "--with-pic"
  ];

  meta = with stdenv.lib; {
    homepage = http://www.ossp.org/pkg/lib/uuid/;
    description = "OSSP uuid ISO-C and C++ shared library";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libossp-uuid-${version}";
  version = "1.6.2";

  src = fetchurl {
    url = "ftp://ftp.ossp.org/pkg/lib/uuid/uuid-${version}.tar.gz";
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
      i686-linux
      ++ x86_64-linux;
  };
}

{ stdenv
, fetchurl
, perl
, bc
, openssl
, mysql_lib
, postgresql
, log4cplus
, boost
, googletest
}:

stdenv.mkDerivation rec {
  name = "kea-${version}";
  version = "1.0.0";

  src = fetchurl {
    url = "https://ftp.isc.org/isc/kea/${version}/${name}.tar.gz";
    sha256 = "1zjs2dbdwa7hk6a2h9dgry64v0985l0sqphisc43s4zr33llz64n";
  };

  nativeBuildInputs = [
    bc
    perl
  ];

  buildInputs = [
    openssl
    mysql_lib
    postgresql
    log4cplus
    boost
  ];

  postPatch = ''
    sed -i 's,enable_static_link=yes,enable_static_link=$enableval,g' configure
  '';

  configureFlags = [
    "--disable-debug"
    "--with-werror"
    # Flag is not a boolean
    #"--disable-static-link"
    "--with-pythonpath"
    # Flag is not a boolean
    "--with-gtest-source=${googletest}/src/gtest"
    "--with-gtest=${googletest}"
    "--without-lcov"
    "--with-openssl=${openssl}"
    "--without-botan-config"
    "--with-dhcp-mysql=${mysql_lib}/bin/mysql_config"
    "--with-dhcp-pgsql=${postgresql}/bin/pg_config"
    "--with-log4cplus"
    "--disable-generate-parser"
    "--disable-generate-docs"
    "--disable-install-configurations"
    "--disable-logger-checks"
  ];

  makeFlags = [
    # Spoof libtool since googletest no longer provides libtool files.
    "GTEST_LDADD=${googletest}/lib/libgtest.so"
  ];

  CXXFLAGS = "-std=c++11";

  preFixup = ''
    sed -i 's,openssl-1.0.0,openssl,g' $out/lib/pkgconfig/dns++.pc
  '';

  meta = with stdenv.lib; {
    license = licenses.mpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

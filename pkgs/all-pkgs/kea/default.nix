{ stdenv, fetchurl
, perl
, bc
, openssl
, libmysql
, postgresql
, log4cplus
, boost
, gtest
}:

stdenv.mkDerivation rec {
  name = "kea-${version}";
  version = "1.0.0";

  src = fetchurl {
    url = "http://ftp.isc.org/isc/kea/${version}/${name}.tar.gz";
    sha256 = "1zjs2dbdwa7hk6a2h9dgry64v0985l0sqphisc43s4zr33llz64n";
  };

  nativeBuildInputs = [
    perl
    bc
  ];

  buildInputs = [
    openssl
    libmysql
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
    "--disable-static-link"
    "--with-pythonpath"
    #"--without-gtest-source"
    "--with-gtest=${gtest}"
    "--without-lcov"
    "--with-openssl=${openssl}"
    "--without-botan-config"
    "--with-dhcp-mysql=${libmysql}/bin/mysql_config"
    "--with-dhcp-pgsql=${postgresql}/bin/pg_config"
    "--with-log4cplus"
    "--disable-generate-parser"
    "--disable-generate-docs"
    "--disable-install-configurations"
    "--disable-logger-checks"
  ];

  preFixup = ''
    sed -i 's,openssl-1.0.0,openssl,g' $out/lib/pkgconfig/dns++.pc
  '';

  meta = with stdenv.lib; {
    license = licenses.mpl2;
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
    maintainers = with maintainers; [
      wkennington
    ];
  };
}

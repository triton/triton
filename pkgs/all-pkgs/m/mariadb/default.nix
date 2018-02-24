{ stdenv
, cmake
, fetchurl
, ninja

, ncurses
, zlib
, xz
, lzo
, lz4
, bzip2
, snappy
, openssl
, pcre
, boost
, judy
, bison
, libarchive
, pam
, libxml2
, kytea
, msgpack-c
, libaio
, libevent
, groff
, jemalloc
, cracklib
, systemd_lib
, numactl
, zeromq
}:

stdenv.mkDerivation rec {
  name = "mariadb-10.2.13";

  src = fetchurl {
    url = "mirror://mariadb/${name}/source/${name}.tar.gz";
    hashOutput = false;
    sha256 = "272e7ed9300a05da9e02f8217a01ed3447c4f5a36a12e5233d62cc7c586fc753";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    bison
    boost
    bzip2
    cracklib
    jemalloc
    judy
    kytea
    libaio
    libarchive
    libevent
    libxml2
    lz4
    lzo
    msgpack-c
    ncurses
    numactl
    openssl
    pam
    #pcre
    snappy
    systemd_lib
    xz
    zeromq
    zlib
  ];

  cmakeFlags = [
    "-DBUILD_CONFIG=mysql_release"
    "-DDEFAULT_CHARSET=utf8"
    "-DDEFAULT_COLLATION=utf8_general_ci"
    "-DENABLED_LOCAL_INFILE=ON"
    "-DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock"
    "-DMYSQL_DATADIR=/var/lib/mysql"
    "-DINSTALL_SYSCONFDIR=etc/mysql"
    "-DINSTALL_INFODIR=share/mysql/docs"
    "-DINSTALL_MANDIR=share/man"
    "-DINSTALL_PLUGINDIR=lib/mysql/plugin"
    "-DINSTALL_SCRIPTDIR=bin"
    "-DINSTALL_INCLUDEDIR=include/mysql"
    "-DINSTALL_DOCREADMEDIR=share/mysql"
    "-DINSTALL_SUPPORTFILESDIR=share/mysql"
    "-DINSTALL_MYSQLSHAREDIR=share/mysql"
    "-DINSTALL_DOCDIR=share/mysql/docs"
    "-DINSTALL_SHAREDIR=share/mysql"
    "-DWITH_INNODB_SNAPPY=ON"
    "-DWITH_READLINE=ON"
    "-DWITH_ZLIB=system"
    "-DWITH_SSL=system"
    #"-DWITH_PCRE=system"  # Temporarily disabled due to bugs
    "-DWITH_LIBARCHIVE=ON"
    "-DWITH_EXTRA_CHARSETS=complex"
    "-DWITH_EMBEDDED_SERVER=ON"
    "-DWITH_ARCHIVE_STORAGE_ENGINE=1"
    "-DWITH_BLACKHOLE_STORAGE_ENGINE=1"
    "-DWITH_INNOBASE_STORAGE_ENGINE=1"
    "-DWITH_PARTITION_STORAGE_ENGINE=1"
    "-DWITHOUT_EXAMPLE_STORAGE_ENGINE=1"
    "-DWITHOUT_FEDERATED_STORAGE_ENGINE=1"
    "-DSECURITY_HARDENED=ON"
    "-DWITH_WSREP=ON"
    "-DWITHOUT_OQGRAPH_STORAGE_ENGINE=1"
  ];

  prePatch = ''
    sed -i 's,[^"]*/var/log,/var/log,g' \
      storage/mroonga/vendor/groonga/CMakeLists.txt
  '';

  postInstall = ''
    sed -i "s,basedir=\"\",basedir=\"$out\",g" \
      "$out"/bin/mysql_install_db

    # Remove superfluous files
    rm -r $out/mysql-test $out/sql-bench $out/data # Don't need testing data
    rm $out/share/man/man1/mysql-test-run.pl.1
    rm $out/bin/rcmysql # Not needed with nixos units
    find $out/bin -name \*test\* -exec rm {} \;

    # Fix the mysql_config
    sed \
      -e 's,-lz,-L${zlib}/lib -lz,g' \
      -e 's,-lssl,-L${openssl}/lib -lssl,g' \
      -i $out/bin/mysql_config

    # Don't install static libraries.
    rm $out/lib/*.a
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "1993 69E5 404B D5FC 7D2F  E43B CBCB 082A 1BB9 43DB";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "An enhanced, drop-in replacement for MySQL";
    homepage = https://mariadb.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

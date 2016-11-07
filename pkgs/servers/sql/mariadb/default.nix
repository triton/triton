{ stdenv, fetchurl, cmake, ncurses, zlib, xz, lzo, lz4, bzip2, snappy
, openssl, pcre, boost, judy, bison, libxml2, ninja, kytea, msgpack-c
, libaio, libevent, groff, jemalloc, cracklib, systemd_lib, numactl, perl
, zeromq
}:

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "mariadb-10.1.19";

  src = fetchurl {
    urls = map (n: "${n}/${name}/source/${name}.tar.gz") [
      "http://downloads.mariadb.org/interstitial"
      "http://sfo1.mirrors.digitalocean.com/mariadb"
      "http://mirror.jmu.edu/pub/mariadb"
    ];
    hashOutput = false;
    sha256 = "5b9373f314e2d1727422fb3795bcf50c1c59005129b35b6cadafae5663251a81";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];
  buildInputs = [
    ncurses openssl zlib xz lzo lz4 bzip2 snappy
    pcre libxml2 boost judy bison libevent cracklib
    jemalloc libaio systemd_lib numactl kytea msgpack-c
    zeromq
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
    "-DWITH_READLINE=ON"
    "-DWITH_ZLIB=system"
    "-DWITH_SSL=system"
    "-DWITH_PCRE=system"
    "-DWITH_EMBEDDED_SERVER=yes"
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
    substituteInPlace cmake/libutils.cmake \
      --replace /usr/bin/libtool libtool
    sed -i 's,[^"]*/var/log,/var/log,g' storage/mroonga/vendor/groonga/CMakeLists.txt
  '';

  postInstall = ''
    substituteInPlace $out/bin/mysql_install_db \
      --replace basedir=\"\" basedir=\"$out\"

    # Remove superfluous files
    rm -r $out/mysql-test $out/sql-bench $out/data # Don't need testing data
    rm $out/share/man/man1/mysql-test-run.pl.1
    rm $out/bin/rcmysql # Not needed with nixos units
    rm $out/bin/mysqlbug # Encodes a path to gcc and not really useful
    find $out/bin -name \*test\* -exec rm {} \;

    # Fix the mysql_config
    sed -i $out/bin/mysql_config \
      -e 's,-lz,-L${zlib}/lib -lz,g' \
      -e 's,-lssl,-L${openssl}/lib -lssl,g'

    # Don't install static libraries.
    rm $out/lib/*.a
  '';

  passthru = {
    mysqlVersion = "5.6";
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "1993 69E5 404B D5FC 7D2F  E43B CBCB 082A 1BB9 43DB";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "An enhanced, drop-in replacement for MySQL";
    homepage    = https://mariadb.org/;
    license     = stdenv.lib.licenses.gpl2;
    maintainers = with stdenv.lib.maintainers; [ wkennington ];
    platforms   = stdenv.lib.platforms.all;
  };
}

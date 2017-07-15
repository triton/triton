{ stdenv
, bc
, bind
, dhcp
, fetchurl
, perl

, boost
#, cassandra
, googletest
, log4cplus
, mariadb-connector-c
, openssl_1-0-2
, postgresql
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "1.2.0";
in
stdenv.mkDerivation rec {
  name = "kea-${version}";

  src = fetchurl {
    url = "https://ftp.isc.org/isc/kea/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "22d15945b13600b56c37213797ca1f3ee9851e6119120aeae08033c4cc52d129";
  };

  nativeBuildInputs = [
    bc
    perl
  ];

  buildInputs = [
    boost
    #cassandra
    log4cplus
    mariadb-connector-c
    openssl_1-0-2
    postgresql
  ];

  postPatch = ''
    find . -name \*.in -and -not -name Makefile.in \
      -exec sed -i 's,@abs_top_\(src\|build\)dir@,/no-such-path,g' {} \;

    find . -name Makefile.in -exec sed -i '/-D[^ =]*=/s,$(abs_top_\(src\|build\)dir),/no-such-path,g' {} \;
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-debug"
    #"--with-werror"
    # Flag is not a boolean
    #"--disable-static-link"
    "--with-pythonpath"
    # Flag is not a boolean
  ] ++ optionals doCheck [
    "--with-gtest-source=${googletest}/share/gtest/src"
    "--with-gtest=${googletest}"
  ] ++ [
    "--without-lcov"
    "--with-openssl=${openssl_1-0-2}"
    "--without-botan-config"
    "--with-dhcp-mysql=${mariadb-connector-c}/bin/mariadb_config"
    "--with-dhcp-pgsql=${postgresql}/bin/pg_config"
    #"--with-cql=${cassandra}/bin/cql_config"
    "--with-log4cplus"
    "--disable-generate-parser"
    "--disable-generate-docs"
    "--disable-install-configurations"
    "--disable-logger-checks"
  ];

  makeFlags = optionals doCheck [
    # Spoof libtool since googletest no longer provides libtool files.
    "GTEST_LDADD=${googletest}/lib/libgtest.so"
  ];

  doCheck = false;

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
      "dhcp_data_dir=$TMPDIR"
    )
  '';

  preFixup = ''
    rm "$out/lib/pkgconfig"/dns++.*
  '';
  
  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sha512.asc") src.urls;
      pgpKeyFile = dhcp.srcVerification.pgpKeyFile;
      pgpKeyFingerprints = bind.srcVerification.pgpKeyFingerprints;
      inherit (src) urls outputHashAlgo outputHash;
    };
  };

  meta = with stdenv.lib; {
    license = licenses.mpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, bc
, bind
, dhcp
, fetchurl
, perl
, python2Packages

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

  version = "1.3.0";
in
stdenv.mkDerivation rec {
  name = "kea-${version}";

  src = fetchurl {
    url = "https://ftp.isc.org/isc/kea/${version}/${name}.tar.gz";
    multihash = "QmSjmvseLKnXDXv8DvBauHqwt13RYDabxE9k7J3UmpMRwj";
    hashOutput = false;
    sha256 = "6edfcdbf2526c218426a1d1a6a6694a4050c97bb8412953a230285d63415c391";
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
    python2Packages.python
  ];

  postPatch = ''
    find . -name \*.in -and -not -name Makefile.in \
      -exec sed -i 's,@abs_top_\(src\|build\)dir@,/no-such-path,g' {} \;

    find . -name Makefile.in -exec sed \
      -e 's,@sysconfdir@,$(sysconfdir),g' \
      -e '/-D[^ =]*=/s,$(abs_top_\(src\|build\)dir),/no-such-path,g' \
      -i  {} \;
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-shell"
  ] ++ optionals doCheck [
    "--with-gtest-source=${googletest}/share/gtest/src"
    "--with-gtest=${googletest}"
  ] ++ [
    "--with-openssl=${openssl_1-0-2}"
    "--without-botan-config"
    "--with-dhcp-mysql=${mariadb-connector-c}/bin/mariadb_config"
    "--with-dhcp-pgsql=${postgresql}/bin/pg_config"
    #"--with-cql=${cassandra}/bin/cql_config"
    "--with-log4cplus"
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

{ stdenv
, fetchurl
, fetchTritonPatch
, makeWrapper

, apr
, expat
, db
, gnused
, mariadb-connector-c
, openldap
, openssl
, postgresql
, sqlite
, unixODBC
}:

stdenv.mkDerivation rec {
  name = "apr-util-1.6.0";

  src = fetchurl {
    url = "mirror://apache/apr/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "8474c93fa74b56ac6ca87449abe3e155723d5f534727f3f33283f6631a48ca4c";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    apr
    db
    expat
    mariadb-connector-c
    openldap
    openssl
    postgresql
    sqlite
    unixODBC
  ];

  configureFlags = [
    "--with-apr=${apr}"
    "--with-expat=${expat}"
    "--with-crypto"
    "--with-openssl=${openssl}"
    "--with-dbm=db53"
    "--with-berkeley-db=${db}"
    "--with-mysql=${mariadb-connector-c}"
    "--with-ldap=ldap"
    "--with-odbc=${unixODBC}"
  ];

  preFixup = ''
    # Fix library references in the -config program
    sed \
      -e 's,LIBS=",\0-L${expat}/lib ,g' \
      -e 's,LDAP_LIBS=",\0-L${openldap}/lib ,g' \
      -e 's,DBM_LIBS=",\0-L${db}/lib ,g' \
      -e "s,$NIX_BUILD_TOP,/no-such-path,g" \
      -i $out/bin/apu-1-config

    # Give apr1 access to sed for runtime invocations
    wrapProgram $out/bin/apu-1-config --prefix PATH : "${gnused}/bin"
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        "5B51 81C2 C0AB 13E5 9DA3  F7A3 EC58 2EB6 39FF 092C"
        # Nick Kew
        "3CE3 BAC2 EB7B BC62 4D1D  22D8 F3B9 D88C B87F 79A9"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A companion library to APR, the Apache Portable Runtime";
    homepage = http://apr.apache.org/;
    license = licenses.asl20;
    maintainers = [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

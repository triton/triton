{ stdenv
, fetchurl
, makeWrapper

, apr
, expat
, db
, gnused
, openldap
, openssl
}:

stdenv.mkDerivation rec {
  name = "apr-util-1.5.4";

  src = fetchurl {
    url = "mirror://apache/apr/${name}.tar.bz2";
    sha256 = "0bn81pfscy9yjvbmyx442svf43s6dhrdfcsnkpxz43fai5qk5kx6";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    apr
    db
    expat
    openldap
    openssl
  ];

  configureFlags = [
    "--with-apr=${apr}"
    "--with-expat=${expat}"
    "--with-crypto"
    "--with-openssl=${openssl}"
    "--with-berkeley-db=${db}"
    "--with-ldap=ldap"
  ];

  preFixup = ''
    # Fix library references in the -config program
    sed \
      -e 's,LIBS=",\0-L${expat}/lib ,g' \
      -e 's,LDAP_LIBS=",\0-L${openldap}/lib ,g' \
      -e 's,DBM_LIBS=",\0-L${db}/lib ,g' \
      -i $out/bin/apu-1-config

    # Give apr1 access to sed for runtime invocations
    wrapProgram $out/bin/apu-1-config --prefix PATH : "${gnused}/bin"
  '';

  meta = with stdenv.lib; {
    description = "A companion library to APR, the Apache Portable Runtime";
    homepage = http://apr.apache.org/;
    license = licenses.asl20;
    maintainers = [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

{ stdenv, fetchurl, makeWrapper, apr, expat, gnused
, sslSupport ? true, openssl
, bdbSupport ? false, db
, ldapSupport ? true, openldap
, cyrus_sasl, autoreconfHook
}:

assert sslSupport -> openssl != null;
assert bdbSupport -> db != null;
assert ldapSupport -> openldap != null;

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "apr-util-1.5.4";

  src = fetchurl {
    url = "mirror://apache/apr/${name}.tar.bz2";
    sha256 = "0bn81pfscy9yjvbmyx442svf43s6dhrdfcsnkpxz43fai5qk5kx6";
  };

  configureFlags = [ "--with-apr=${apr}" "--with-expat=${expat}" ]
    ++ optional true "--with-crypto"
    ++ optional sslSupport "--with-openssl=${openssl}"
    ++ optional bdbSupport "--with-berkeley-db=${db}"
    ++ optional ldapSupport "--with-ldap=ldap";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ apr expat ]
    ++ optional sslSupport openssl
    ++ optional bdbSupport db
    ++ optional ldapSupport openldap;

  preFixup = ''
    # Fix library references in the -config program
    sed \
      -e 's,LIBS=",\0-L${expat}/lib ,g' \
  '' + optionalString (bdbSupport) ''
      -e 's,LDAP_LIBS=",\0-L${openldap}/lib ,g' \
  '' + optionalString (sslSupport) ''
      -e 's,DBM_LIBS=",\0-L${db}/lib ,g' \
  '' + ''
      -i $out/bin/apu-1-config

    # Give apr1 access to sed for runtime invocations
    wrapProgram $out/bin/apu-1-config --prefix PATH : "${gnused}/bin"
  '';

  passthru = {
    inherit sslSupport bdbSupport ldapSupport;
  };

  meta = {
    homepage = http://apr.apache.org/;
    description = "A companion library to APR, the Apache Portable Runtime";
    maintainers = [ stdenv.lib.maintainers.eelco ];
  };
}

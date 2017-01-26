{ stdenv
, fetchurl
, fetchTritonPatch
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
    hashOutput = false;
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

  patches = [
		(fetchTritonPatch {
      rev = "a29a999dbbcc6a7965e65c31ab9bc2938f738f2c";
      file = "a/apr-util/openssl-1.1.patch";
      sha256 = "88225f93632ee4fb2fa1e0c5ee7a177b1299e1b55f644c567b4763f8c8acbe54";
    })
  ];

  postPatch = ''
    sed -i 's,BN_init,BN_new,g' configure
  '';

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
      -e "s,$NIX_BUILD_TOP,/no-such-path,g" \
      -i $out/bin/apu-1-config

    # Give apr1 access to sed for runtime invocations
    wrapProgram $out/bin/apu-1-config --prefix PATH : "${gnused}/bin"
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "5B51 81C2 C0AB 13E5 9DA3  F7A3 EC58 2EB6 39FF 092C";
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

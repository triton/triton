{ stdenv
, bison
, fetchurl
, perl

, libedit
, libverto
, openldap
, openssl

, type ? ""
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;
in

let
  libOnly = type == "lib";
in

stdenv.mkDerivation rec {
  name = "${type}krb5-${version}";
  version = "1.14.2";

  src = fetchurl {
    url = "${meta.homepage}dist/krb5/1.14/krb5-${version}.tar.gz";
    allowHashOutput = false;
    sha256 = "6bcad7e6778d1965e4ce4af21d2efdc15b274c5ce5c69031c58e4c954cda8b27";
  };

  prePatch= ''
    cd src
  '';

  nativeBuildInputs = [
    bison
    perl
  ];

  # We prefer openssl over nss since it supports all crypto features
  # We prefer libedit as it is more stable in krb5
  buildInputs = [
    libverto
    openssl
  ] ++ optionals (!libOnly) [
    libedit
    openldap
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-athena"
    "--without-vague-errors"
    "--with-crypto-impl=openssl"
    "--with-pkinit-crypto-impl=openssl"
    "--with-tls-impl=openssl"
    "--enable-aesni"
    "--enable-kdc-lookaside-cache"
    "--enable-pkinit"
    "--${if libOnly then "without" else "with"}-libedit"
    "--without-readline"
    "--with-system-verto"
    "--${if libOnly then "without" else "with"}-ldap"
    "--without-tcl"
    "--without-system-db"  # Requires db v1.85
  ];

  buildPhase = optionalString libOnly ''
    (cd util; make)
    (cd include; make)
    (cd lib; make)
    (cd build-tools; make)
  '';

  installPhase = optionalString libOnly ''
    mkdir -p $out/{bin,include/{gssapi,gssrpc,kadm5,krb5},lib/pkgconfig,sbin,share/{et,man/man1}}
    (cd util; make install)
    (cd include; make install)
    (cd lib; make install)
    (cd build-tools; make install)
    rm -rf $out/{sbin,share}
    find $out/bin -type f | grep -v 'krb5-config' | xargs rm
  '';

  passthru = rec {
    newVersion = "1.14.2";
    srcVerification = fetchurl rec {
      failEarly = true;
      url = "${meta.homepage}dist/krb5/1.14/krb5-${newVersion}.tar.gz";
      pgpsigUrl = "${url}.asc";
      pgpKeyFingerprint = "2C73 2B1C 0DBE F678 AB3A  F606 A32F 17FD 0055 C305";
      sha256 = "6bcad7e6778d1965e4ce4af21d2efdc15b274c5ce5c69031c58e4c954cda8b27";
    };
  };

  meta = with stdenv.lib; {
    description = "MIT Kerberos 5";
    homepage = http://web.mit.edu/kerberos/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };

  passthru.implementation = "krb5";
}

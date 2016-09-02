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

  libOnly = type == "lib";

  tarballUrls = major: patch: [
    "https://web.mit.edu/kerberos/dist/krb5/${major}/krb5-${major}.${patch}.tar.gz"
  ];

  major = "1.14";
  patch = "3";
in
stdenv.mkDerivation rec {
  name = "${type}krb5-${major}.${patch}";

  src = fetchurl {
    urls = tarballUrls major patch;
    hashOutput = false;
    sha256 = "cd4620d520cf0df0dd8791309912df2bb20fcba76790b9fba4e25c1da08ff2c9";
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
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.14" "3";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "2C73 2B1C 0DBE F678 AB3A  F606 A32F 17FD 0055 C305";
      sha256 = "cd4620d520cf0df0dd8791309912df2bb20fcba76790b9fba4e25c1da08ff2c9";
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

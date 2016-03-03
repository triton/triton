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
  libOnly = type == "lib";
  inherit (stdenv.lib)
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "${type}krb5-${version}";
  version = "1.14.1";

  src = fetchurl {
    url = "${meta.homepage}dist/krb5/1.14/krb5-${version}.tar.gz";
    sha256 = "168sdwnsrw3hpx4kjcn49jklinrjik2fsgasrv85nvr4fi2s9yn8";
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
    (cd util; make -j $NIX_BUILD_CORES)
    (cd include; make -j $NIX_BUILD_CORES)
    (cd lib; make -j $NIX_BUILD_CORES)
    (cd build-tools; make -j $NIX_BUILD_CORES)
  '';

  installPhase = optionalString libOnly ''
    mkdir -p $out/{bin,include/{gssapi,gssrpc,kadm5,krb5},lib/pkgconfig,sbin,share/{et,man/man1}}
    (cd util; make -j $NIX_BUILD_CORES install)
    (cd include; make -j $NIX_BUILD_CORES install)
    (cd lib; make -j $NIX_BUILD_CORES install)
    (cd build-tools; make -j $NIX_BUILD_CORES install)
    rm -rf $out/{sbin,share}
    find $out/bin -type f | grep -v 'krb5-config' | xargs rm
  '';

  meta = with stdenv.lib; {
    description = "MIT Kerberos 5";
    homepage = http://web.mit.edu/kerberos/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };

  passthru.implementation = "krb5";
}

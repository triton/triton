{ stdenv
, bison
, fetchurl
, perl

, cyrus-sasl
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
    "https://web.mit.edu/kerberos/dist/krb5/${major}/krb5-${version major patch}.tar.gz"
  ];

  version = major: patch: "${major}${optionalString (patch != null) ".${patch}"}";

  major = "1.18";
  patch = null;
in
stdenv.mkDerivation rec {
  name = "${type}krb5-${version major patch}";

  src = fetchurl {
    urls = tarballUrls major patch;
    multihash = "QmdxBF7sN2joQtVqoY5HzGL3nK4fLPmDwrMqHV7teXf2KA";
    hashOutput = false;
    sha256 = "73913934d711dcf9d5f5605803578edb44b9a11786df3c1b2711f4e1752f2c88";
  };

  nativeBuildInputs = [
    bison
    perl
  ];

  # We prefer openssl over nss since it supports all crypto features
  # We prefer libedit as it is more stable in krb5
  buildInputs = [
    openssl
  ] ++ optionals (!libOnly) [
    cyrus-sasl
    libedit
    libverto
    openldap
  ];

  prePatch = ''
    cd src
  '';

  # KRad is only used interally and is the only dependency on libverto
  # If we don't provide verto it will be built unnecessarily so disable it
  postPatch = optionalString libOnly ''
    grep -q '^SUBDIRS=.*krad' lib/Makefile.in
    sed -i '/^SUBDIRS=/s,\(krad\|apputils\),,g' lib/Makefile.in

    grep -q 'krad.h' include/Makefile.in
    sed -i '/INSTALL.*krad.h/d' include/Makefile.in

    grep -q '^MAYBE_VERTO.*verto' util/Makefile.in
    sed -i '/^MAYBE_VERTO/s, verto,,g' util/Makefile.in
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-athena"
    "--${if libOnly then "without" else "with"}-ldap"
    "--with-crypto-impl=openssl"
    "--with-tls-impl=openssl"
    "--${if libOnly then "without" else "with"}-libedit"
    "--${if libOnly then "without" else "with"}-system-verto"
  ];

  buildPhase = optionalString libOnly ''
    runHook preBuild

    (cd util; make)
    (cd include; make)
    (cd lib; make)
    (cd build-tools; make)

    runHook postBuild
  '';

  installPhase = optionalString libOnly ''
    runHook preInstall

    mkdir -p $out/{bin,include/{gssapi,gssrpc,kadm5,krb5},lib/pkgconfig,sbin,share/{et,man/man1}}
    (cd util; make install)
    (cd include; make install)
    (cd lib; make install)
    (cd build-tools; make install)
    rm -rf $out/{sbin,share}
    find $out/bin -type f | grep -v 'krb5-config' | xargs rm

    runHook postInstall
  '';

  postInstall = ''
    ln -s libgssapi_krb5.so "$out"/lib/libgssapi.so
  '';

  passthru = rec {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.17" null;
      sha256 = "5a6e2284a53de5702d3dc2be3b9339c963f9b5397d3fbbc53beb249380a781f5";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprints = [
          "2C73 2B1C 0DBE F678 AB3A  F606 A32F 17FD 0055 C305"
          "C449 3CB7 39F4 A89F 9852  CBC2 0CBA 0857 5F83 72DF"
        ];
      };
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

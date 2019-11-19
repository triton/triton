{ stdenv
, bison
, fetchurl
, lib
, perl

, openssl
}:

let
  inherit (lib)
    optionalString;

  tarballUrls = major: patch: [
    "https://web.mit.edu/kerberos/dist/krb5/${major}/krb5-${version major patch}.tar.gz"
  ];

  version = major: patch: "${major}${optionalString (patch != null) ".${patch}"}";

  major = "1.17";
  patch = null;
in
stdenv.mkDerivation rec {
  name = "libkrb5-${version major patch}";

  src = fetchurl {
    urls = tarballUrls major patch;
    multihash = "QmWC2q7VSM1FjPQ9K5fvKK2hHAdreHqfLuR8fLfPf7nAEk";
    hashOutput = false;
    sha256 = "5a6e2284a53de5702d3dc2be3b9339c963f9b5397d3fbbc53beb249380a781f5";
  };

  nativeBuildInputs = [
    bison.bin
    perl
  ];

  # We prefer openssl over nss since it supports all crypto features
  buildInputs = [
    openssl
  ];

  # Doesn't support shared + static config
  addStatic = false;

  prePatch = ''
    cd src
  '';

  # KRad is only used interally and is the only dependency on libverto
  # If we don't provide verto it will be built unnecessarily so disable it
  postPatch = ''
    grep -q '^SUBDIRS=.*krad' lib/Makefile.in
    sed -i '/^SUBDIRS=/s,\(krad\|apputils\),,g' lib/Makefile.in

    grep -q 'krad.h' include/Makefile.in
    sed -i '/INSTALL.*krad.h/d' include/Makefile.in

    grep -q '^MAYBE_VERTO.*verto' util/Makefile.in
    sed -i '/^MAYBE_VERTO/s, verto,,g' util/Makefile.in

    grep -q '@LIBDIR' include/osconf.hin
    sed -i "s,@LIBDIR,$lib/lib," include/osconf.hin
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-athena"
    "--with-crypto-impl=openssl"
    "--with-tls-impl=openssl"
  ];

  CC_WRAPPER_CFLAGS = [
    "-ULIBDIR"
    "-DLIBDIR=\"${placeholder "lib"}/lib\""
    "-UBINDIR"
    "-DBINDIR=\"${placeholder "lib"}/bin\""
    "-USBINDIR"
    "-DSBINDIR=\"${placeholder "lib"}/bin\""
  ];

  buildPhase = ''
    runHook preBuild

    buildFlagsArray+=(
      "MODULE_DIR=$lib/lib/krb5/plugins"
      "GSS_MODULE_DIR=$lib/lib/gss"
      "KRB5_LOCALEDIR=$lib/share/locale"
    )

    local actualMakeFlags
    commonMakeFlags 'build'
    printMakeFlags 'build'

    (cd util; make "''${actualMakeFlags[@]}")
    (cd include; make "''${actualMakeFlags[@]}")
    (cd lib; make "''${actualMakeFlags[@]}")
    (cd build-tools; make "''${actualMakeFlags[@]}")

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    grep -r "$dev" .

    mkdir -p $dev/{bin,include/{gssapi,gssrpc,kadm5,krb5},lib/pkgconfig,sbin,share/{et,man/man1}}
    (cd util; make install)
    (cd include; make install)
    (cd lib; make install)
    (cd build-tools; make install)
    rm -rf $dev/{sbin,share}
    find $dev/bin -type f | grep -v 'krb5-config' | xargs rm

    runHook postInstall
  '';

  postInstall = ''
    ln -s libgssapi_krb5.so "$dev"/lib/libgssapi.so

    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  outputs = [
    "dev"
    "lib"
  ];

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

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
    "https://web.mit.edu/kerberos/dist/krb5/${major}/krb5-${version major patch}.tar.gz"
  ];

  version = major: patch: "${major}${optionalString (patch != null) ".${patch}"}";

  major = "1.16";
  patch = "1";
in
stdenv.mkDerivation rec {
  name = "${type}krb5-${version major patch}";

  src = fetchurl {
    urls = tarballUrls major patch;
    multihash = "QmZmFCaMRTJyDyCXMbfL2Y89RyV31kDmj8pv3cXrnpsG9q";
    hashOutput = false;
    sha256 = "214ffe394e3ad0c730564074ec44f1da119159d94281bbec541dc29168d21117";
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
    "--with-tls-impl=openssl"
    #"--enable-asan"  # FIXME: causes undefined reference errors
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
      urls = tarballUrls "1.16" "1";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprints = [
        "2C73 2B1C 0DBE F678 AB3A  F606 A32F 17FD 0055 C305"
        "C449 3CB7 39F4 A89F 9852  CBC2 0CBA 0857 5F83 72DF"
      ];
      sha256 = "214ffe394e3ad0c730564074ec44f1da119159d94281bbec541dc29168d21117";
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

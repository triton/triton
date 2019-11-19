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

  major = "1.17";
  patch = null;
in
stdenv.mkDerivation rec {
  name = "${type}krb5-${version major patch}";

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
  # We prefer libedit as it is more stable in krb5
  buildInputs = [
    cyrus-sasl
    libedit
    libverto
    openldap
    openssl
  ];

  prePatch = ''
    cd src
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-athena"
    "--with-ldap"
    "--with-crypto-impl=openssl"
    "--with-tls-impl=openssl"
    "--with-libedit"
    "--with-system-verto"
  ];

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

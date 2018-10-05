{ stdenv
, autogen
, fetchurl
, which

, cryptodev_headers
, gmp
, libidn2
, libtasn1
, libunistring
, nettle
, p11-kit
, trousers
, unbound
}:

let
  tarballUrls = major: minor: [
    "mirror://gnupg/gnutls/v${major}/gnutls-${major}.${minor}.tar.xz"
  ];

  major = "3.6";
  minor = "4";
  version = "${major}.${minor}";
in
stdenv.mkDerivation rec {
  name = "gnutls-${version}";

  src = fetchurl {
    urls = tarballUrls major minor;
    hashOutput = false;
    sha256 = "c663a792fbc84349c27c36059181f2ca86c9442e75ee8b0ad72f5f9b35deab3a";
  };

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-doc"
    "--enable-manpages"
    "--disable-ssl2-support"
    "--enable-cryptodev"
    "--disable-tests"
    "--disable-full-test-suite"
    "--with-default-trust-store-file=/etc/ssl/certs/ca-certificates.crt"
    "--with-trousers-lib=${trousers}/lib"
    "--disable-dependency-tracking"
  ];

  nativeBuildInputs = [
    autogen
    which
  ];

  buildInputs = [
    cryptodev_headers
    gmp
    libidn2
    libtasn1
    libunistring
    nettle
    p11-kit
    trousers
    unbound
  ];

  passthru = {
    # Gnupg depends on this so we have to decouple this fetch from the rest of the build.
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "3.6" "4";
      inherit (src)
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "1F42 4189 05D8 206A A754  CCDC 29EE 58B9 9686 5171";
      };
      outputHash = "c663a792fbc84349c27c36059181f2ca86c9442e75ee8b0ad72f5f9b35deab3a";
    };
  };

  meta = with stdenv.lib; {
    description = "The GNU Transport Layer Security Library";
    homepage = http://www.gnu.org/software/gnutls/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

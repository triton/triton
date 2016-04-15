{ stdenv
, autogen
, autoreconfHook
, fetchurl
, perl

, gmp
, libidn
, libtasn1
, lzo
, nettle
, p11_kit
, trousers
, unbound
, zlib
}:

let
  tarballUrls = major: minor: [
    "ftp://ftp.gnutls.org/gcrypt/gnutls/v${major}/gnutls-${major}.${minor}.tar.xz"
  ];
  major = "3.4";
  minor = "11";
in

stdenv.mkDerivation rec {
  name = "gnutls-${version}";
  version = "${major}.${minor}";

  src = fetchurl {
    urls = tarballUrls major minor;
    allowHashOutput = false;
    sha256 = "70ef9c9f95822d363036c6e6b5479750e5b7fc34f50e750c3464a98ec65a9ab8";
  };

  # This fixes some broken parallel dependencies
  postPatch = ''
    sed -i 's,^BUILT_SOURCES =,\0 systemkey-args.h,g' src/Makefile.am
  '';

  configureFlags = [
    "--with-default-trust-store-file=/etc/ssl/certs/ca-certificates.crt"
    "--disable-dependency-tracking"
    "--enable-fast-install"
  ];

  nativeBuildInputs = [
    autogen
    autoreconfHook
    perl
  ];

  buildInputs = [
    lzo
    nettle
    libtasn1
    libidn
    p11_kit
    zlib
    gmp
    trousers
    unbound
  ];

  doCheck = true;

  passthru = {
    # Gnupg depends on this so we have to decouple this fetch from the rest of the build.
    srcVerified = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "3.4" "11";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyId = "96865171";
      pgpKeyFingerprint = "1F42 4189 05D8 206A A754  CCDC 29EE 58B9 9686 5171";
      inherit (src) outputHashAlgo;
      outputHash = "70ef9c9f95822d363036c6e6b5479750e5b7fc34f50e750c3464a98ec65a9ab8";
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

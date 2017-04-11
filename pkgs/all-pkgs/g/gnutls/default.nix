{ stdenv
, autogen
, autoreconfHook
, fetchurl
, perl

, cryptodev_headers
, gmp
, libidn
, libtasn1
, libunistring
, lzo
, nettle
, p11-kit
, trousers
, unbound
, zlib
}:

let
  tarballUrls = major: minor: [
    "mirror://gnupg/gnutls/v${major}/gnutls-${major}.${minor}.tar.xz"
  ];

  major = "3.5";
  minor = "11";
  version = "${major}.${minor}";
in
stdenv.mkDerivation rec {
  name = "gnutls-${version}";

  src = fetchurl {
    urls = tarballUrls major minor;
    hashOutput = false;
    sha256 = "51765cc5579e250da77fbd7871507c517d01b15353cc40af7b67e9ec7b6fe28f";
  };

  # This fixes some broken parallel dependencies
  postPatch = ''
    sed -i 's,^BUILT_SOURCES =,\0 systemkey-args.h,g' src/Makefile.am
  '';

  configureFlags = [
    "--with-default-trust-store-file=/etc/ssl/certs/ca-certificates.crt"
    "--with-trousers-lib=${trousers}/lib"
    "--disable-dependency-tracking"
    "--enable-manpages"
    "--enable-cryptodev"
    "--enable-fast-install"
  ];

  nativeBuildInputs = [
    autogen
    autoreconfHook
    perl
  ];

  buildInputs = [
    cryptodev_headers
    gmp
    libidn
    libtasn1
    libunistring
    lzo
    nettle
    p11-kit
    trousers
    unbound
    zlib
  ];

  passthru = {
    # Gnupg depends on this so we have to decouple this fetch from the rest of the build.
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "3.5" "11";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "1F42 4189 05D8 206A A754  CCDC 29EE 58B9 9686 5171";
      inherit (src) outputHashAlgo;
      outputHash = "51765cc5579e250da77fbd7871507c517d01b15353cc40af7b67e9ec7b6fe28f";
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

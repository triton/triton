{ stdenv
, autogen
, autoreconfHook
, fetchurl
, perl

, cryptodev_headers
, gmp
, libidn2
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

  major = "3.6";
  minor = "2";
  version = "${major}.${minor}";
in
stdenv.mkDerivation rec {
  name = "gnutls-${version}";

  src = fetchurl {
    urls = tarballUrls major minor;
    hashOutput = false;
    sha256 = "bcd5db7b234e02267f36b5d13cf5214baac232b7056a506252b7574ea7738d1f";
  };

  # This fixes some broken parallel dependencies
  postPatch = ''
    sed -i 's,^BUILT_SOURCES =,\0 systemkey-args.h,g' src/Makefile.am
  '';

  configureFlags = [
    "--disable-ssl3-support"
    "--disable-ssl2-support"
    # TODO: re-enable when the code is fixed (broken in 3.6.1 -> 3.6.2)
    #"--enable-cryptodev"
    "--disable-tests"
    "--disable-valgrind-tests"
    "--disable-full-test-suite"
    "--with-default-trust-store-file=/etc/ssl/certs/ca-certificates.crt"
    "--with-trousers-lib=${trousers}/lib"
    "--disable-dependency-tracking"
    "--enable-manpages"
    "--enable-fast-install"
  ];

  nativeBuildInputs = [
    autogen
    autoreconfHook
    perl
  ];

  buildInputs = [
    #cryptodev_headers
    gmp
    libidn2
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
      urls = tarballUrls "3.6" "2";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "1F42 4189 05D8 206A A754  CCDC 29EE 58B9 9686 5171";
      inherit (src) outputHashAlgo;
      outputHash = "bcd5db7b234e02267f36b5d13cf5214baac232b7056a506252b7574ea7738d1f";
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

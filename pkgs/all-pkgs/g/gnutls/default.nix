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
    "mirror://gnupg/gnutls/v${major}/gnutls-${major}.${minor}.tar.xz"
  ];

  major = "3.5";
  minor = "5";
in
stdenv.mkDerivation rec {
  name = "gnutls-${version}";
  version = "${major}.${minor}";

  src = fetchurl {
    urls = tarballUrls major minor;
    hashOutput = false;
    sha256 = "86994fe7804ee16d2811e366b9bf2f75304f8e470ae0e3716d60ffeedac0e529";
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

  passthru = {
    # Gnupg depends on this so we have to decouple this fetch from the rest of the build.
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "3.5" "5";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "1F42 4189 05D8 206A A754  CCDC 29EE 58B9 9686 5171";
      inherit (src) outputHashAlgo;
      outputHash = "86994fe7804ee16d2811e366b9bf2f75304f8e470ae0e3716d60ffeedac0e529";
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

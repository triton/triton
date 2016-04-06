{ stdenv
, autogen
, autoreconfHook
, fetchurl
, perl

, gmp
, libidn
, libtasn1
, lzip
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
  minor = "10";
in
stdenv.mkDerivation rec {
  name = "gnutls-${version}";
  version = "${major}.${minor}";

  src = fetchurl {
    urls = tarballUrls major minor;
    allowHashOutput = false;
    sha256 = "17zmpnqpdh5n409zcvhlc16cj16s15q3blfbxxzgycxxmjsc4cka";
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
    lzip
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
      urls = tarballUrls "3.4" "10";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyId = "96865171";
      pgpKeyFingerprint = "1F42 4189 05D8 206A A754  CCDC 29EE 58B9 9686 5171 ";
      inherit (src) outputHashAlgo;
      outputHash = "17zmpnqpdh5n409zcvhlc16cj16s15q3blfbxxzgycxxmjsc4cka";
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
      i686-linux
      ++ x86_64-linux;
  };
}

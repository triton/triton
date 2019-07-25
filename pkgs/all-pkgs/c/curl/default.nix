{ stdenv
, fetchurl

, brotli
, c-ares
, krb5_lib
, libidn2
, libmetalink
, libpsl
, libssh2
, nghttp2_lib
, openldap
, openssl
, zlib

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString
    optionals;

  tarballUrls = version: [
    "https://curl.haxx.se/download/curl-${version}.tar.xz"
  ];

  version = "7.65.3";
in
stdenv.mkDerivation rec {
  name = "curl-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmYCTCy1EQYK9YGH9kL7Mab25cp7N7N9e8gwYVF9rvggB4";
    hashOutput = false;
    sha256 = "f2d98854813948d157f6a91236ae34ca4a1b4cb302617cebad263d79b0235fea";
  };

  buildInputs = [
    brotli
    c-ares
    nghttp2_lib
    openssl
    zlib
    libidn2
  ] ++ optionals (type != "minimal") [
    krb5_lib
    libmetalink
    libpsl
    libssh2
    openldap
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-ares"
    "--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
    "--with-ca-path=/etc/ssl/certs"
    "--with-ca-fallback"
  ] ++ optionals (type == "minimal") [
    "--disable-manual"
  ] ++ optionals (type != "minimal") [
    "--with-libmetalink"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "7.65.3";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "27ED EAF2 2F3A BCEB 50DB  9A12 5CC9 08FD B71E 12C2";
      };
      inherit (src) outputHashAlgo;
      outputHash = "f2d98854813948d157f6a91236ae34ca4a1b4cb302617cebad263d79b0235fea";
    };
  };

  meta = with stdenv.lib; {
    description = "A command line tool for transferring files with URL syntax";
    homepage = http://curl.haxx.se/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

{ stdenv
, fetchurl
, perl

, c-ares
, krb5_lib
, libidn2
, libpsl
, libssh2
, nghttp2_lib
, openldap
, openssl
, rtmpdump
, zlib

# Extra arguments
, suffix ? ""
}:

let
  inherit (stdenv.lib)
    optionalString
    optionals;

  isFull = suffix == "full";
  nameSuffix = optionalString (suffix != "") "-${suffix}";

  tarballUrls = version: [
    "https://curl.haxx.se/download/curl-${version}.tar.bz2"
  ];

  version = "7.59.0";
in
stdenv.mkDerivation rec {
  name = "curl${nameSuffix}-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmcQZuAm8PEBacogYNiTyeZd4dKtik6pYAGcPKuXreMGep";
    hashOutput = false;
    sha256 = "b5920ffd6a8c95585fb95070e0ced38322790cb335c39d0dab852d12e157b5a0";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    c-ares
    nghttp2_lib
    openssl
    zlib
  ] ++ optionals isFull [
    krb5_lib
    libidn2
    libpsl
    libssh2
    openldap
    rtmpdump
  ];

  configureFlags = [
    "--enable-http"
    "--enable-ftp"
    "--enable-file"
    "--${if isFull then "enable" else "disable"}-ldap"
    "--${if isFull then "enable" else "disable"}-ldaps"
    "--enable-rtsp"
    "--enable-proxy"
    "--enable-dict"
    "--enable-telnet"
    "--enable-tftp"
    "--enable-pop3"
    "--enable-imap"
    "--enable-smb"
    "--enable-smtp"
    "--enable-gopher"
    "--enable-manual"
    "--enable-libcurl_option"
    "--${if stdenv.cc.cc.isGNU then "enable" else "disable"}-libgcc"
    "--with-zlib"
    "--enable-ipv4"
    "--with-gssapi"
    "--without-winssl"
    "--without-darwinssl"
    "--with-ssl"
    "--without-gnutls"
    "--without-polarssl"
    "--without-mbedtls"
    "--without-cyassl"
    "--without-nss"
    "--without-axtls"
    "--${if isFull then "with" else "without"}-libpsl"
    "--without-libmetalink"
    # "--without-zsh-functions-dir"
    "--${if isFull then "with" else "without"}-libssh2"
    "--${if isFull then "with" else "without"}-librtmp"
    "--disable-versioned-symbols"
    "--without-winidn"
    "--${if isFull then "with" else "without"}-libidn"
    "--with-nghttp2"
    "--disable-sspi"
    "--enable-crypto-auth"
    "--enable-tls-srp"
    "--enable-unix-sockets"
    "--enable-cookies"
    "--enable-ares"
    "--enable-rt"
    "--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
    "--with-ca-fallback"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "7.59.0";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "27ED EAF2 2F3A BCEB 50DB  9A12 5CC9 08FD B71E 12C2";
      inherit (src) outputHashAlgo;
      outputHash = "b5920ffd6a8c95585fb95070e0ced38322790cb335c39d0dab852d12e157b5a0";
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

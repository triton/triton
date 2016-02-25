{ stdenv
, fetchurl
, perl

, c-ares
, gss
, libidn
, nghttp2_lib
, libssh2
, openldap
, openssl
, rtmpdump
, zlib

# Extra arguments
, suffix ? ""
}:

let
  inherit (stdenv.lib)
    mkEnable
    mkWith
    optionalString
    optionals;
  isFull = suffix == "full";
  nameSuffix = optionalString (suffix != "") "-${suffix}";
in
stdenv.mkDerivation rec {
  name = "curl${nameSuffix}-${version}";
  version = "7.47.1";

  src = fetchurl {
    url = "http://curl.haxx.se/download/curl-${version}.tar.bz2";
    sha256 = "13z9gba3q2ybp50z0gdkzhwcx9m0i7qkvm278yz4pql2jfml7inx";
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
    gss
    libidn
    libssh2
    openldap
    rtmpdump
  ];

  configureFlags = [
    (mkEnable true                    "http"              null)
    (mkEnable true                    "ftp"               null)
    (mkEnable true                    "file"              null)
    (mkEnable isFull                  "ldap"              null)
    (mkEnable isFull                  "ldaps"             null)
    (mkEnable true                    "rtsp"              null)
    (mkEnable true                    "proxy"             null)
    (mkEnable true                    "dict"              null)
    (mkEnable true                    "telnet"            null)
    (mkEnable true                    "tftp"              null)
    (mkEnable true                    "pop3"              null)
    (mkEnable true                    "imap"              null)
    (mkEnable true                    "smb"               null)
    (mkEnable true                    "smtp"              null)
    (mkEnable true                    "gopher"            null)
    (mkEnable true                    "manual"            null)
    (mkEnable true                    "libcurl_option"    null)
    (mkEnable false                   "libgcc"            null) # TODO: Enable on gcc
    (mkWith   true                    "zlib"              null)
    (mkEnable true                    "ipv4"              null)
    (mkWith   true                    "gssapi"            null)
    (mkWith   false                   "winssl"            null)
    (mkWith   false                   "darwinssl"         null)
    (mkWith   true                    "ssl"               null)
    (mkWith   false                   "gnutls"            null)
    (mkWith   false                   "polarssl"          null)
    (mkWith   false                   "mbedtls"           null)
    (mkWith   false                   "cyassl"            null)
    (mkWith   false                   "nss"               null)
    (mkWith   false                   "axtls"             null)
    (mkWith   false                   "libpsl"            null)
    (mkWith   false                   "libmetalink"       null)
    #(mkWith   false                   "zsh-functions-dir" null)
    (mkWith   isFull                  "libssh2"           null)
    (mkWith   isFull                  "librtmp"           null)
    (mkEnable false                   "versioned-symbols" null)
    (mkWith   false                   "winidn"            null)
    (mkWith   isFull                  "libidn"            null)
    (mkWith   true                    "nghttp2"           null)
    (mkEnable false                   "sspi"              null)
    (mkEnable true                    "crypto-auth"       null)
    (mkEnable true                    "tls-srp"           null)
    (mkEnable true                    "unix-sockets"      null)
    (mkEnable true                    "cookies"           null)
    (mkEnable true                    "ares"              null)
    (mkEnable true                    "rt"                null)
    (mkWith   true                    "ca-bundle"         "/etc/ssl/certs/ca-certificates.crt")
  ];

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

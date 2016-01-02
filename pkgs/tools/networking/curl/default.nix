{ stdenv, fetchurl, perl

# Optional Dependencies
, zlib ? null, openssl ? null, libssh2 ? null, libnghttp2 ? null, c-ares ? null
, gss ? null, rtmpdump ? null, openldap ? null, libidn ? null

# Extra arguments
, suffix ? ""
}:

with stdenv;
with stdenv.lib;
let
  isFull = suffix == "full";
  nameSuffix = optionalString (suffix != "") "-${suffix}";

  # Normal Depedencies
  optOpenssl = shouldUsePkg openssl;
  optLibnghttp2 = shouldUsePkg libnghttp2;
  optZlib = shouldUsePkg zlib;
  optC-ares = shouldUsePkg c-ares;

  # Full dependencies
  optLibssh2 = if !isFull then null else shouldUsePkg libssh2;
  optGss = if !isFull then null else shouldUsePkg gss;
  optRtmpdump = if !isFull then null else shouldUsePkg rtmpdump;
  optOpenldap = if !isFull then null else shouldUsePkg openldap;
  optLibidn = if !isFull then null else shouldUsePkg libidn;
in
stdenv.mkDerivation rec {
  name = "curl${nameSuffix}-${version}";
  version = "7.46.0";

  src = fetchurl {
    url = "http://curl.haxx.se/download/curl-${version}.tar.bz2";
    sha256 = "1bcm646jgq70mpkwa6n6skff9fzbb4y4liqvzaq6sjzdv36jdmxp";
  };

  nativeBuildInputs = [ perl ];
  propagatedBuildInputs = [
    optZlib optOpenssl optLibssh2 optLibnghttp2 optC-ares
    optGss optRtmpdump optOpenldap optLibidn
  ];

  # Make curl honor CURL_CA_BUNDLE & SSL_CERT_FILE
  postConfigure = ''
    echo '#define CURL_CA_BUNDLE (getenv("CURL_CA_BUNDLE") ? getenv("CURL_CA_BUNDLE") : getenv("SSL_CERT_FILE"))' >> lib/curl_config.h
  '';

  configureFlags = [
    (mkEnable true                    "http"              null)
    (mkEnable true                    "ftp"               null)
    (mkEnable true                    "file"              null)
    (mkEnable (optOpenldap != null)   "ldap"              null)
    (mkEnable (optOpenldap != null)   "ldaps"             null)
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
    (mkWith   (optZlib != null)       "zlib"              null)
    (mkEnable true                    "ipv4"              null)
    (mkWith   (optGss != null)        "gssapi"            null)
    (mkWith   false                   "winssl"            null)
    (mkWith   false                   "darwinssl"         null)
    (mkWith   (optOpenssl != null)    "ssl"               null)
    (mkWith   false                   "gnutls"            null)
    (mkWith   false                   "polarssl"          null)
    (mkWith   false                   "mbedtls"           null)
    (mkWith   false                   "cyassl"            null)
    (mkWith   false                   "nss"               null)
    (mkWith   false                   "axtls"             null)
    (mkWith   false                   "libpsl"            null)
    (mkWith   false                   "libmetalink"       null)
    #(mkWith   false                   "zsh-functions-dir" null)
    (mkWith   (optLibssh2 != null)    "libssh2"           null)
    (mkWith   (optRtmpdump!= null)    "librtmp"           null)
    (mkEnable false                   "versioned-symbols" null)
    (mkWith   false                   "winidn"            null)
    (mkWith   (optLibidn != null)     "libidn"            null)
    (mkWith   (optLibnghttp2 != null) "nghttp2"           null)
    (mkEnable false                   "sspi"              null)
    (mkEnable true                    "crypto-auth"       null)
    (mkEnable (optOpenssl != null)    "tls-srp"           null)
    (mkEnable true                    "unix-sockets"      null)
    (mkEnable true                    "cookies"           null)
    (mkEnable (optC-ares != null)     "ares"              null)
    (mkEnable true                    "rt"                null)
  ];

  meta = {
    description = "A command line tool for transferring files with URL syntax";
    homepage    = http://curl.haxx.se/;
    license     = licenses.mit;
    platforms   = platforms.all;
    maintainers = with maintainers; [ lovek323 wkennington ];
  };
}

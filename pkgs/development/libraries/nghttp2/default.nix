{ stdenv, fetchurl

# Optinal Dependencies
, openssl ? null, libev ? null, zlib ? null, jansson ? null, boost ? null
, libxml2 ? null, jemalloc ? null

# Extra argument
, prefix ? ""
}:

with stdenv;
with stdenv.lib;
let
  isLib = prefix == "lib";

  optOpenssl = if isLib then null else shouldUsePkg openssl;
  optLibev = if isLib then null else shouldUsePkg libev;
  optZlib = if isLib then null else shouldUsePkg zlib;

  hasApp = optOpenssl != null && optLibev != null && optZlib != null;

  optJansson = if isLib then null else shouldUsePkg jansson;
  #optBoost = if isLib then null else shouldUsePkg boost;
  optBoost = null; # Currently detection is broken
  optLibxml2 = if !hasApp then null else shouldUsePkg libxml2;
  optJemalloc = if !hasApp then null else shouldUsePkg jemalloc;
in
stdenv.mkDerivation rec {
  name = "${prefix}nghttp2-${version}";
  version = "1.7.1";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/nghttp2/releases/download/v${version}/nghttp2-${version}.tar.xz";
    sha256 = "05m687bhvrrnqaf18fl6h5y06a4v7j9aai8gmj5cwpflfgfnya7i";
  };

  buildInputs = [ optJansson optBoost optLibxml2 optJemalloc ]
    ++ optionals hasApp [ optOpenssl optLibev optZlib ];

  configureFlags = [
    (mkEnable false                 "werror"          null)
    (mkEnable false                 "debug"           null)
    (mkEnable true                  "threads"         null)
    (mkEnable hasApp                "app"             null)
    (mkEnable (optJansson != null)  "hpack-tools"     null)
    (mkEnable (optBoost != null)    "asio-lib"        null)
    (mkEnable false                 "examples"        null)
    (mkEnable false                 "python-bindings" null)
    (mkEnable false                 "failmalloc"      null)
    (mkWith   (optLibxml2 != null)  "libxml2"         null)
    (mkWith   (optJemalloc != null) "jemalloc"        null)
    (mkWith   false                 "spdylay"         null)
    (mkWith   false                 "neverbleed"      null)
    (mkWith   false                 "cython"          null)
    (mkWith   false                 "mruby"           null)
    #(mkWith   false                 "libonly"         null)
  ];

  meta = {
    homepage = http://nghttp2.org/;
    description = "an implementation of HTTP/2 in C";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ wkennington ];
  };
}

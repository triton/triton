{ stdenv
, fetchurl

, gd
, geoip
, gperftools
, libatomic_ops
, libxml2
, libxslt
, pcre
, openssl
, zlib

, channel ? "stable"
}:

let
  sources = import ./sources.nix;

  source = sources."${channel}";

  inherit (stdenv.lib)
    versionAtLeast
    versionOlder;
in
stdenv.mkDerivation rec {
  name = "nginx-${source.version}";

  src = fetchurl {
    url = "http://nginx.org/download/${name}.tar.gz";
    inherit (source) sha256;
  };

  buildInputs = [
    gd
    geoip
    gperftools
    libatomic_ops
    libxml2
    libxslt
    pcre
    openssl
    zlib
  ];

  # Needed to allow libxml2 support to be compiled in
  NIX_CFLAGS_COMPILE = [
    "-I${libxml2}/include/libxml2"
  ];

  configureFlags = [
    "--conf-path=/etc/nginx/nginx.conf"
    "--error-log-path=/var/log/nginx/error.log"
    "--http-log-path=/var/log/nginx/acces.log"
    "--pid-path=/run/nginx/nginx.pid"
    "--lock-path=/run/nginx/nginx.lock"
    "--user=nginx"
    "--group=nginx"

    (if versionOlder source.version "1.9.0" then "--with-rtsig_module" else null)
    "--with-select_module"
    "--with-poll_module"
    "--with-threads"
    "--with-file-aio"
    "--with-ipv6"
    "--with-http_ssl_module"
    (if versionOlder source.version "1.9.0" then "--with-http_spdy_module" else null)
    (if versionAtLeast source.version "1.9.0" then "--with-http_v2_module" else null)
    "--with-http_realip_module"
    "--with-http_addition_module"
    "--with-http_xslt_module"
    "--with-http_image_filter_module"
    "--with-http_geoip_module"
    "--with-http_sub_module"
    "--with-http_dav_module"
    "--with-http_flv_module"
    "--with-http_mp4_module"
    "--with-http_gunzip_module"
    "--with-http_gzip_static_module"
    "--with-http_auth_request_module"
    "--with-http_random_index_module"
    "--with-http_secure_link_module"
    "--with-http_degradation_module"
    (if versionAtLeast source.version "1.9.0" then "--with-http_slice_module" else null)
    "--with-http_stub_status_module"
    # "--with-http_perl_module"
    "--with-mail"
    "--with-mail_ssl_module"
    (if versionAtLeast source.version "1.9.0" then "--with-stream" else null)
    (if versionAtLeast source.version "1.9.0" then "--with-stream_ssl_module" else null)
    "--with-google_perftools_module"
    "--with-cpp_test_module"
    "--with-pcre"
    "--with-pcre-jit"
    "--with-libatomic"
  ];
  
  # The install paths are a disaster
  preInstall = ''
    mkdir -p $TMPDIR/install
    installFlagsArray+=("DESTDIR=$TMPDIR/install")
  '';
  
  postInstall = ''
    mkdir -p $out/share/nginx
    mv $TMPDIR/install/$out/html $out/share/nginx
    mv $TMPDIR/install/$out/sbin $out/bin
    mv $TMPDIR/install/etc $out/etc
  '';

  passthru = {
    sourceTarball = fetchurl {
      urls = src.urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFile = ./mdounin.key;
      inherit (source) sha256;
    };
  };

  meta = with stdenv.lib; {
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl

, geoip
, gperftools
, libatomic_ops
, libgd
, libxml2
, libxslt
, pcre
, openssl
, zlib

, channel
}:

let
  inherit ((import ./sources.nix)."${channel}")
    multihash
    sha256
    version;
in
stdenv.mkDerivation rec {
  name = "nginx-${version}";

  src = fetchurl {
    url = "https://nginx.org/download/${name}.tar.gz";
    hashOutput = false;
    inherit
      multihash
      sha256;
  };

  buildInputs = [
    geoip
    gperftools
    libatomic_ops
    libgd
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

  postPatch = ''
    sed -i '/-Werror/d' auto/cc/gcc
  '';

  configureFlags = [
    "--conf-path=/etc/nginx/nginx.conf"
    "--error-log-path=/var/log/nginx/error.log"
    "--http-log-path=/var/log/nginx/access.log"
    "--pid-path=/run/nginx/nginx.pid"
    "--lock-path=/run/nginx/nginx.lock"
    "--user=nginx"
    "--group=nginx"

    "--with-select_module"
    "--with-poll_module"
    "--with-threads"
    "--with-file-aio"
    "--with-http_ssl_module"
    "--with-http_v2_module"
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
    "--with-http_slice_module"
    "--with-http_stub_status_module"
    # "--with-http_perl_module"
    "--with-mail"
    "--with-mail_ssl_module"
    "--with-stream"
    "--with-stream_ssl_module"
    "--with-google_perftools_module"
    "--with-cpp_test_module"
    "--with-pcre"
    "--with-pcre-jit"
    "--with-libatomic"
    "--with-stream_realip_module"
    "--with-stream_geoip_module"
    "--with-stream_ssl_preread_module"
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
    srcVerification = fetchurl {
      failEarly = true;
      urls = src.urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFile = ./mdounin.key;
      inherit sha256;
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

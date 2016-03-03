{ stdenv
, fetchurl
, perl

, apr
, apr-util
, pcre
, openssl
, openldap
, libxml2
, zlib
}:

stdenv.mkDerivation rec {
  version = "2.4.18";
  name = "apache-httpd-${version}";

  src = fetchurl {
    url = "mirror://apache/httpd/httpd-${version}.tar.bz2";
    sha256 = "0k7xm6ldzvakzq39nw6b39190ihlkc28all2gkvckxa1vr8b0i06";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    libxml2
    openldap
  ];

  # Required for ‘pthread_cancel’.
  NIX_LDFLAGS = "-lgcc_s";

  configureFlags = [
    "--with-apr=${apr}"
    "--with-apr-util=${apr-util}"
    "--with-z=${zlib}"
    "--with-pcre=${pcre}"
    "--disable-maintainer-mode"
    "--disable-debugger-mode"
    "--enable-mods-shared=all"
    "--enable-mpms-shared=all"
    "--enable-cern-meta"
    "--enable-imagemap"
    "--enable-cgi"
    "--enable-proxy"
    "--enable-ssl"
    "--with-ssl=${openssl}"
    "--disable-lua"
    "--with-libxml2=${libxml2}/include/libxml2"
  ];

  postInstall = ''
    echo "removing manual"
    rm -rf $out/manual
  '';

  meta = with stdenv.lib; {
    description = "Apache HTTPD, the world's most popular web server";
    homepage = http://httpd.apache.org/;
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

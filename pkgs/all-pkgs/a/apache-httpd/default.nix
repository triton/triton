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

let
  version = "2.4.27";
in
stdenv.mkDerivation rec {
  name = "apache-httpd-${version}";

  src = fetchurl {
    url = "mirror://apache/httpd/httpd-${version}.tar.bz2";
    hashOutput = false;
    sha256 = "71fcc128238a690515bd8174d5330a5309161ef314a326ae45c7c15ed139c13a";
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "A93D 62EC C3C8 EA12 DB22  0EC9 34EA 76E6 7914 85A8";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Apache HTTPD, the world's most popular web server";
    homepage = http://httpd.apache.org/;
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

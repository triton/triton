{ stdenv
, asciidoctor_2
, docbook-xsl-ns
, fetchurl
, gettext
, libxslt
, makeWrapper
, perlPackages
, xmlto

, coreutils_small
, cpio
, curl
, expat
, gawk_small
, gnugrep
, gnused_small
, openssl
, pcre2_lib
, python3
, zlib
}:

let
  inherit (stdenv.lib)
    concatStringsSep;

  path = [
    coreutils_small
    gawk_small
    gettext
    gnugrep
    gnused_small
  ];

  version = "2.24.1";

  tarballUrls = [
    "mirror://kernel/software/scm/git/git-${version}.tar"
  ];

  sendEmailLib = concatStringsSep ":" (map (n: "${n}/${perlPackages.perl.libPrefix}") [
    # SSL
    perlPackages.IOSocketSSL
    perlPackages.NetSSLeay
    perlPackages.URI

    # Auth
    perlPackages.AuthenSASL
    perlPackages.DigestHMAC
  ]);
in
stdenv.mkDerivation rec {
  name = "git-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "723f24dce8fdd621a308b6187553fce7d5244205c065fe0a3aebd0b7c3f88562";
  };

  nativeBuildInputs = [
    asciidoctor_2
    docbook-xsl-ns
    gettext
    libxslt
    makeWrapper
    perlPackages.perl
    xmlto
  ];

  buildInputs = [
    curl
    expat
    openssl
    pcre2_lib
    zlib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--with-sane-tool-path=${concatStringsSep ":" path}"
    "--with-libpcre"
    "--without-tcltk"
  ];

  makeFlags = [
    "PERL_PATH=${perlPackages.perl}/bin/perl"
    "PYTHON_PATH=${python3.interpreter}"
    "GNU_ROFF=1"
    "USE_ASCIIDOCTOR=1"
    "INSTALL_SYMLINKS=1"
  ];

  preBuild = ''
    cat config.mak.autogen
  '';

  buildFlags = [
    "V=1"
    "all"
    "man"
  ];

  installTargets = [
    "install"
    "install-man"
  ];

  preFixup = ''
    wrapProgram "$out"/libexec/git-core/git-send-email \
      --prefix PERL5LIB : '${sendEmailLib}' \
      --set SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpDecompress = true;
        pgpsigUrls = map (n: "${n}.sign") tarballUrls;
        pgpKeyFingerprint = "96E0 7AF2 5771 9559 80DA  D100 20D0 4E5A 7136 60A7";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Distributed version control system";
    homepage = http://git-scm.com/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

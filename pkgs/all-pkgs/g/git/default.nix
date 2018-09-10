{ stdenv
, asciidoc
, docbook_xml_dtd_45
, docbook-xsl
, fetchurl
, gettext
, libxslt
, makeWrapper
, perl
, xmlto

, coreutils
, cpio
, curl
, expat
, gawk
, gnugrep
, gnused
, openssl
, pcre2
, python
, zlib
}:

let
  inherit (stdenv.lib)
    concatStringsSep;

  path = [
    coreutils
    gawk
    gettext
    gnugrep
    gnused
  ];

  version = "2.19.0";

  tarballUrls = [
    "mirror://kernel/software/scm/git/git-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "git-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "180feff58fc0d965d23ea010aa2c69ead92ec318eb9b09cf737529aec62f3ef4";
  };

  nativeBuildInputs = [
    asciidoc
    docbook_xml_dtd_45
    docbook-xsl
    gettext
    libxslt
    makeWrapper
    perl
    xmlto
  ];

  buildInputs = [
    curl
    expat
    openssl
    pcre2
    zlib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--with-sane-tool-path=${concatStringsSep ":" path}"
    "--with-libpcre"
    "--without-tcltk"
  ];

  # required to support pthread_cancel()
  #NIX_LDFLAGS = "-lgcc_s";

  makeFlags = [
    "PERL_PATH=${perl}/bin/perl"
    "PYTHON_PATH=${python}/bin/python"
    "GNU_ROFF=1"
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

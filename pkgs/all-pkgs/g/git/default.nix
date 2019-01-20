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

, coreutils_small
, cpio
, curl
, expat
, gawk_small
, gnugrep
, gnused_small
, openssl
, pcre2_lib
, python
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

  version = "2.20.1";

  tarballUrls = [
    "mirror://kernel/software/scm/git/git-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "git-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "9d2e91e2faa2ea61ba0a70201d023b36f54d846314591a002c610ea2ab81c3e9";
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

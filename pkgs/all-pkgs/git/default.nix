{ stdenv
, fetchurl
, gettext
, makeWrapper

, coreutils
, cpio
, curl
, expat
, gawk
, gnugrep
, gnused
, openssl
, pcre
, perl
, python
, zlib
}:

let
  path = [
    coreutils
    gawk
    gettext
    gnugrep
    gnused
  ];
in
stdenv.mkDerivation rec {
  name = "git-${version}";
  version = "2.7.2";

  src = fetchurl {
    url = "https://www.kernel.org/pub/software/scm/git/git-${version}.tar.xz";
    sha256 = "086ga30ksijfxad085ply83ddf955d2b8qxph5sw6c9hab77j15j";
  };

  patches = [
    ./symlinks-in-bin.patch
  ];

  nativeBuildInputs = [
    gettext
    makeWrapper
  ];

  buildInputs = [
    curl
    expat
    openssl
    pcre
    zlib
  ];

  # required to support pthread_cancel()
  NIX_LDFLAGS = "-lgcc_s";

  makeFlags = [
    "SHELL_PATH=${stdenv.shell}"
    "SANE_TOOL_PATH=${stdenv.lib.concatStringsSep ":" path}"
    "USE_LIBPCRE=1"
    "GNU_ROFF=1"
    "PERL_PATH=${perl}/bin/perl"
    "PYTHON_PATH=${python}/bin/python"
    "NO_TCLTK=1"
    "HAVE_CLOCK_GETTIME=1"
    "HAVE_CLOCK_MONOTONIC=1"
    "NO_INSTALL_HARDLINKS=1"
    "prefix=\${out}"
    "sysconfdir=/etc"
  ];

  meta = with stdenv.lib; {
    homepage = http://git-scm.com/;
    description = "Distributed version control system";
    license = licenses.gpl2;
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
    maintainers = with maintainers; [
      wkennington
    ];
  };
}

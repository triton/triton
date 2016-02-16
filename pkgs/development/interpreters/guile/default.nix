{ fetchurl, stdenv, libtool, readline, gmp, boehmgc, libunistring
, libffi, gawk, makeWrapper }:

stdenv.mkDerivation rec {
  name = "guile-2.0.11";

  src = fetchurl {
    url = "mirror://gnu/guile/${name}.tar.xz";
    sha256 = "1qh3j7308qvsjgwf7h94yqgckpbgz2k3yqdkzsyhqcafvfka9l5f";
  };

  nativeBuildInputs = [ makeWrapper gawk ];
  buildInputs = [ readline libtool libunistring libffi gmp boehmgc ];

  # A native Guile 2.0 is needed to cross-build Guile.
  selfNativeBuildInput = true;

  patches = [ ./disable-gc-sensitive-tests.patch ./eai_system.patch ./clang.patch ];

  # Fixes for parallel building
  postPatch = ''
    sed -i libguile/Makefile.in \
      -e 's,^.c.x:$,.c.x: $(BUILT_SOURCES),g' \
      -e 's,DOT_X_FILES.*: ,\0$(DOT_I_FILES) ,g'
  '';

  # Explicitly link against libgcc_s, to work around the infamous
  # "libgcc_s.so.1 must be installed for pthread_cancel to work".
  LDFLAGS = "-lgcc_s";

  postInstall = ''
    wrapProgram $out/bin/guile-snarf --prefix PATH : "${gawk}/bin"

    # XXX: See http://thread.gmane.org/gmane.comp.lib.gnulib.bugs/18903 for
    # why `--with-libunistring-prefix' and similar options coming from
    # `AC_LIB_LINKFLAGS_BODY' don't work on NixOS/x86_64.
    sed -i "$out/lib/pkgconfig/guile-2.0.pc"    \
        -e 's|-lunistring|-L${libunistring}/lib -lunistring|g ;
            s|^Cflags:\(.*\)$|Cflags: -I${libunistring}/include \1|g ;
            s|-lltdl|-L${libtool}/lib -lltdl|g'
  '';

  # make check doesn't work on darwin
  doCheck = true;

  setupHook = ./setup-hook-2.0.sh;

  meta = {
    description = "Embeddable Scheme implementation";
    homepage    = http://www.gnu.org/software/guile/;
    license     = stdenv.lib.licenses.lgpl3Plus;
    maintainers = with stdenv.lib.maintainers; [ ludo lovek323 ];
    platforms   = stdenv.lib.platforms.all;
  };
}

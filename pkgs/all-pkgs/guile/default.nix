{ stdenv
, fetchurl
, makeWrapper

, boehmgc
, gawk
, gmp
, libffi
, libunistring
, libtool
, readline
}:

stdenv.mkDerivation rec {
  name = "guile-2.0.11";

  src = fetchurl {
    url = "mirror://gnu/guile/${name}.tar.xz";
    sha256 = "1qh3j7308qvsjgwf7h94yqgckpbgz2k3yqdkzsyhqcafvfka9l5f";
  };

  nativeBuildInputs = [
    makeWrapper
  ];
  
  buildInputs = [
    boehmgc
    gmp
    libffi
    libtool
    libunistring
    readline
  ];

  # A native Guile 2.0 is needed to cross-build Guile.
  selfNativeBuildInput = true;

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

  setupHook = ./setup-hook-2.0.sh;

  meta = with stdenv.lib; {
    description = "Embeddable Scheme implementation";
    homepage = http://www.gnu.org/software/guile/;
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

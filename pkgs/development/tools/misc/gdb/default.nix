{ fetchurl, stdenv, ncurses, readline, gmp, mpfr, expat, texinfo, zlib
, dejagnu, perl, pkgconfig
, python ? null
, guile ? null
, target ? null
}:

let
  basename = "gdb-7.10.1";
in

stdenv.mkDerivation rec {
  name = basename + stdenv.lib.optionalString (target != null)
      ("-" + target.config);

  src = fetchurl {
    url = "mirror://gnu/gdb/${basename}.tar.xz";
    sha256 = "1mfnjcwnwm5cg4rc9pncs9v356a0bz6ymjyac56mbj6784yjzir5";
  };

  nativeBuildInputs = [ pkgconfig texinfo perl ];

  buildInputs = [ ncurses readline gmp mpfr expat zlib python guile ]
    ++ stdenv.lib.optional doCheck dejagnu;

  configureFlags = with stdenv.lib;
    [ "--with-gmp=${gmp}" "--with-mpfr=${mpfr}" "--with-system-readline"
      "--with-system-zlib" "--with-expat" "--with-libexpat-prefix=${expat}"
      "--with-separate-debug-dir=/run/current-system/sw/lib/debug"
    ]
    ++ optional (target != null) "--target=${target.config}";

  postInstall =
    '' # Remove Info files already provided by Binutils and other packages.
       rm -v $out/share/info/bfd.info
    '';

  # TODO: Investigate & fix the test failures.
  doCheck = false;

  meta = with stdenv.lib; {
    description = "The GNU Project debugger";
    homepage = http://www.gnu.org/software/gdb/;
    license = stdenv.lib.licenses.gpl3Plus;
    platforms = with platforms; linux;
    maintainers = with maintainers; [ ];
  };
}

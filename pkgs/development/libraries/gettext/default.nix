{ stdenv, fetchurl, libiconv, xz }:

stdenv.mkDerivation rec {
  name = "gettext-0.19.7";

  src = fetchurl {
    url = "mirror://gnu/gettext/${name}.tar.gz";
    sha256 = "0gy2b2aydj8r0sapadnjw8cmb8j2rynj28d5qs1mfa800njd51jk";
  };

  outputs = [ "out" "doc" ];

  patchPhase = ''
   substituteInPlace gettext-tools/projects/KDE/trigger --replace "/bin/pwd" pwd
   substituteInPlace gettext-tools/projects/GNOME/trigger --replace "/bin/pwd" pwd
   substituteInPlace gettext-tools/src/project-id --replace "/bin/pwd" pwd
  '';

  # On cross building, gettext supposes that the wchar.h from libc
  # does not fulfill gettext needs, so it tries to work with its
  # own wchar.h file, which does not cope well with the system's
  # wchar.h and stddef.h (gcc-4.3 - glibc-2.9)
  preConfigure = ''
    if test -n "$crossConfig"; then
      echo gl_cv_func_wcwidth_works=yes > cachefile
      configureFlags="$configureFlags --cache-file=`pwd`/cachefile"
    fi
  '';

  buildInputs = [ xz ] ++ stdenv.lib.optional (!stdenv.isLinux) libiconv;

  enableParallelBuilding = true;

  crossAttrs = {
    buildInputs = stdenv.lib.optional (stdenv ? ccCross && stdenv.ccCross.libc ? libiconv)
      stdenv.ccCross.libc.libiconv.crossDrv;
    # Gettext fails to guess the cross compiler
    configureFlags = "CXX=${stdenv.cross.config}-g++";
  };

  meta = {
    description = "Well integrated set of translation tools and documentation";

    homepage = http://www.gnu.org/software/gettext/;

    maintainers = [ ];
    platforms = stdenv.lib.platforms.all;
  };
}

{ stdenv
, fetchTritonPatch
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "gnumake-${version}";
  version = "4.1";

  src = fetchurl {
    url = "mirror://gnu/make/make-${version}.tar.bz2";
    sha256 = "19gwwhik3wdwn0r42b7xcihkbxvjl9r2bdal8nifc3k5i4rn3iqb";
  };

  patchFlags = [
    "-p0"
  ];

  patches = [
    # Purity: don't look for library dependencies (of the form `-lfoo') in /lib
    # and /usr/lib. It's a stupid feature anyway. Likewise, when searching for
    # included Makefiles, don't look in /usr/include and friends.
    (fetchTritonPatch {
      rev = "ebb8c6e18d124886be220fe157b41382f77a8a36";
      file = "gnumake/impure-dirs.patch";
      sha256 = "47e2b15f79a9d5b4fa54661e3e18ff24cfbb112f6061684fbb770541b66c5728";
    })

    # Don't segfault if we can't get a tty name.
    (fetchTritonPatch {
      rev = "ebb8c6e18d124886be220fe157b41382f77a8a36";
      file = "gnumake/no-tty-name.patch";
      sha256 = "b666267d98eedea29e1aab41254763b78fe83fc008ccaf26d7e6d4ac966e4c84";
    })
  ];

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/make/;
    description = "A tool to control the generation of non-source files from sources";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      simons
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

{ stdenv, fetchurl, m4, zlib, bzip2, xz }:

stdenv.mkDerivation rec {
  name = "elfutils-${version}";
  version = "0.164";

  src = fetchurl {
    urls = [
      "http://fedorahosted.org/releases/e/l/elfutils/${version}/${name}.tar.bz2"
      "mirror://gentoo/${name}.tar.bz2"
      ];
    sha256 = "002r2r46lq44f1phhz8r5pi4jli3ls5944p8gxmx04laj8jw10wn";
  };

  configureFlags = [
    "--enable-deterministic-archives"
  ];

  nativeBuildInputs = [ m4 ];
  buildInputs = [ zlib bzip2 xz ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = https://fedorahosted.org/elfutils/;
    platforms = platforms.all;
  };
}

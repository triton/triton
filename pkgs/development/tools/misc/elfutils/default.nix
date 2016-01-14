{ stdenv, fetchurl, m4, zlib, bzip2, xz }:

stdenv.mkDerivation rec {
  name = "elfutils-${version}";
  version = "0.165";

  src = fetchurl {
    urls = [
      "http://fedorahosted.org/releases/e/l/elfutils/${version}/${name}.tar.bz2"
      "mirror://gentoo/${name}.tar.bz2"
      ];
    sha256 = "0wp91hlh9n0ismikljf63558rzdwim8w1s271grsbaic35vr5z57";
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

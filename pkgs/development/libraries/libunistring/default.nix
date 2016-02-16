{ fetchurl, stdenv }:

stdenv.mkDerivation rec {
  name = "libunistring-0.9.6";

  src = fetchurl {
    url = "mirror://gnu/libunistring/${name}.tar.gz";
    sha256 = "0ixxmgpgh2v8ifm6hbwsjxl023myk3dfnj7wnvmqjivza31fw9cn";
  };

  # XXX: There are test failures on non-GNU systems, see
  # http://lists.gnu.org/archive/html/bug-libunistring/2010-02/msg00004.html .
  doCheck = true;

  # One of the tests fails to compile for 0.9.6 when run in parallel
  parallelCheck = false;

  meta = {
    homepage = http://www.gnu.org/software/libunistring/;
    description = "Unicode string library";
    license = stdenv.lib.licenses.lgpl3Plus;
    platforms = stdenv.lib.platforms.all;
  };
}

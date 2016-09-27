{ stdenv
, fetchTritonPatch
, fetchurl

, bzip2
, libnatspec
}:

stdenv.mkDerivation {
  name = "unzip-6.0";

  src = fetchurl {
    url = mirror://sourceforge/infozip/unzip60.tar.gz;
    multihash = "QmXo6yz71MZYwxNcd76XVvjNjP9B8Ngynn5naodRWurAb8";
    sha256 = "0dxx11knh3nk95p2gg2ak777dd11pr7jx5das2g49l262scrcv83";
  };

  patches = [
    ./CVE-2014-8139.diff
    ./CVE-2014-8140.diff
    ./CVE-2014-8141.diff
    ./CVE-2014-9636.diff
    ./CVE-2015-7696.diff
    ./CVE-2015-7697.diff
    (fetchTritonPatch {
      rev = "4b3bc1c3e645b919a385c408f004bf8c1a161c74";
      file = "u/unzip/unzip-6.0-natspec.patch";
      sha256 = "cf7b6146b034e5687e77c328a9e55efc68ddb75636fdcce84853995ab60082dd";
    })
  ];

  nativeBuildInputs = [ bzip2 ];

  buildInputs = [
    bzip2
    libnatspec
  ];

  makefile = "unix/Makefile";

  NIX_LDFLAGS = [
    "-lbz2"
    "-lnatspec"
  ];

  buildFlags = "generic D_USE_BZ2=-DUSE_BZIP2 L_BZ2=-lbz2";

  preConfigure = ''
    sed -i -e 's@CF="-O3 -Wall -I. -DASM_CRC $(LOC)"@CF="-O3 -Wall -I. -DASM_CRC -DLARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 $(LOC)"@' unix/Makefile
  '';

  installFlags = "prefix=$(out)";

  setupHook = ./setup-hook.sh;

  meta = {
    homepage = http://www.info-zip.org;
    description = "An extraction utility for archives compressed in .zip format";
    license = stdenv.lib.licenses.free; # http://www.info-zip.org/license.html
    platforms = stdenv.lib.platforms.all;
  };
}

{ stdenv, fetchurl, perl, zlib }:

stdenv.mkDerivation rec {
  name = "libzip-1.0.1";

  src = fetchurl {
    url = "http://www.nih.at/libzip/${name}.tar.gz";
    sha256 = "0j9xgybby3njli075rsq8whdf25a7m0n2ks88jncq1aiix6r3vqc";
  };

  nativeBuildInputs = [ perl ];
  propagatedBuildInputs = [ zlib ];

  preInstall = ''
    patchShebangs man/handle_links
  '';

  # At least mysqlWorkbench cannot find zipconf.h; I think also openoffice
  # had this same problem.  This links it somewhere that mysqlworkbench looks.
  postInstall = ''
    ( cd $out/include ; ln -s ../lib/libzip/include/zipconf.h zipconf.h )
  '';

  meta = {
    homepage = http://www.nih.at/libzip;
    description = "A C library for reading, creating and modifying zip archives";
  };
}

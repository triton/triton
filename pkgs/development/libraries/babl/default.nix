{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "babl-0.1.14";

  src = fetchurl {
    url = "http://ftp.gtk.org/pub/babl/0.1/${name}.tar.bz2";
    sha256 = "0kvxmmpms6m0ksbpgqwn1r6knxazlskcbp1zh9qm9xzqr09b3p76";
  };

  meta = { 
    description = "Image pixel format conversion library";
    homepage = http://gegl.org/babl/;
    license = stdenv.lib.licenses.gpl3;
  };
}

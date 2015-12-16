{ stdenv, fetchurl, atk, glibmm, pkgconfig }:

stdenv.mkDerivation rec {
  name = "atkmm-2.24.2";

  src = fetchurl {
    url = "mirror://gnome/sources/atkmm/2.24/${name}.tar.xz";
    sha256 = "ff95385759e2af23828d4056356f25376cfabc41e690ac1df055371537e458bd";
  };

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ atk glibmm ];
}

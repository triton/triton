{ stdenv, fetchurl, pkgconfig, flex, bison, libxslt
, glib, libiconv, libintlOrEmpty
}:

let
  major = "0.30";
  minor = "0";
  sha256 = "61f0337b000f7ed6ef8c1fea87e0047d9bd7c0f91dd9c5b4eb70fd3fb883dedf";
in
stdenv.mkDerivation rec {
  name = "vala-${major}.${minor}";

  src = fetchurl {
    url = "mirror://gnome/sources/vala/${major}/${name}.tar.xz";
    inherit sha256;
  };

  nativeBuildInputs = [ pkgconfig flex bison ];
  buildInputs = [ glib ];

  meta = {
    description = "Compiler for GObject type system";
    homepage = "http://live.gnome.org/Vala";
    license = stdenv.lib.licenses.lgpl21Plus;
    platforms = stdenv.lib.platforms.unix;
    maintainers = with stdenv.lib.maintainers; [ antono lethalman ];
  };
}

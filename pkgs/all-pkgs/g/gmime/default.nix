{ stdenv
, fetchurl

, glib
, libgpg-error
, zlib
}:

stdenv.mkDerivation rec {
  name = "gmime-2.6.22";

  src = fetchurl {
    url = "mirror://gnome/sources/gmime/2.6/${name}.tar.xz";
    sha256 = "c25f9097d5842a4808f1d62faf5eace24af2c51d6113da58d559a3bfe1d5553a";
  };

  buildInputs = [
    glib
    libgpg-error
    zlib
  ];

  meta = with stdenv.lib; {
    homepage = http://spruce.sourceforge.net/gmime/;
    description = "A C/C++ library for manipulating MIME messages";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl

, glib
, libgpg-error
, zlib
}:

stdenv.mkDerivation rec {
  name = "gmime-2.6.23";

  src = fetchurl {
    url = "mirror://gnome/sources/gmime/2.6/${name}.tar.xz";
    sha256 = "7149686a71ca42a1390869b6074815106b061aaeaaa8f2ef8c12c191d9a79f6a";
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

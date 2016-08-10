{ stdenv
, fetchurl

, glib
, exiv2
}:

stdenv.mkDerivation rec {
  name = "gexiv2-0.10.3";

  src = fetchurl {
    url = "https://download.gnome.org/sources/gexiv2/0.10/${name}.tar.xz";
    sha256 = "390cfb966197fa9f3f32200bc578d7c7f3560358c235e6419657206a362d3988";
  };
  
  buildInputs = [
    glib
    exiv2
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

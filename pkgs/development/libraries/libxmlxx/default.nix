{ stdenv
, fetchurl
, perl

, glibmm
, libxml2
}:

let
  major = "3.0";
  minor = "0";
  version = "${major}.${minor}";
in
stdenv.mkDerivation rec {
  name = "libxml++-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libxml++/${major}/${name}.tar.xz";
    sha256 = "2ff3640417729d357bada2e3049061642e0b078c323a8e0d37ae68df96547952";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    glibmm
    libxml2
  ];

  configureFlags = [
    "--disable-documentation" #doesn't build without this for some reason
  ];

  meta = with stdenv.lib; {
    homepage = http://libxmlplusplus.sourceforge.net/;
    description = "C++ wrapper for the libxml2 XML parser library";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

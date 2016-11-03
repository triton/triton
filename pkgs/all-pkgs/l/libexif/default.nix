{ stdenv
, fetchurl
, gettext
}:

let
  version = "0.6.21";
in
stdenv.mkDerivation rec {
  name = "libexif-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libexif/libexif/${version}/${name}.tar.bz2";
    sha256 = "06nlsibr3ylfwp28w8f5466l6drgrnydgxrm4jmxzrmk5svaxk8n";
  };

  nativeBuildInputs = [
    gettext
  ];

  meta = with stdenv.lib; {
    homepage = http://libexif.sourceforge.net/;
    description = "A library to read and manipulate EXIF data in digital photographs";
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}

{ stdenv
, fetchurl
}:

let
  major = "0.1";
  patch = "20";
  version = "${major}.${patch}";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = [
      "https://download.gimp.org/pub/babl/${major}/${name}.tar.bz2"
      "http://ftp.gtk.org/pub/babl/${major}/${name}.tar.bz2"
    ];
    sha256 = "0010909979d4f025d734944722c76eb49e61e412608dbbe4f00857bc8cf59314";
  };

  meta = with stdenv.lib; {
    description = "Image pixel format conversion library";
    homepage = http://gegl.org/babl/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libjpeg-${version}";
  version = "9b";

  src = fetchurl {
    url = "http://www.ijg.org/files/jpegsrc.v${version}.tar.gz";
    sha256 = "0lnhpahgdwlrkd41lx6cr90r199f8mc6ydlh7jznj5klvacd63r4";
  };

  meta = with stdenv.lib; {
    description = "A library that implements the JPEG image file format";
    homepage = http://www.ijg.org/;
    license = licenses.ijg;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

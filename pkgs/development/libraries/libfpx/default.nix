{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "libfpx-1.3.1-4";

  src = fetchurl {
    url = "mirror://imagemagick/delegates/${name}.tar.xz";
    sha256 = "0pbvxbp30zqjpc0q71qbl15cb47py74c4d6a8qv1mqa6j81pb233";
  };

  # This dead code causes a duplicate symbol error in Clang so just remove it
  postPatch = stdenv.lib.optionalString stdenv.cc.isClang ''
    substituteInPlace jpeg/ejpeg.h --replace "int No_JPEG_Header_Flag" ""
  '';

  meta = with stdenv.lib; {
    homepage = http://www.imagemagick.org;
    description = "A library for manipulating FlashPIX images";
    license = "Flashpix";
    platforms = platforms.all;
    maintainers = with maintainers; [ wkennington ];
  };
}

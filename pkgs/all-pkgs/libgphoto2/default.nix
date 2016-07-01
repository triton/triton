{ stdenv
, fetchurl
, flex
, gettext
, libtool

, libexif
, libgd
, libjpeg-turbo_1-4
#, libltdl
, libusb
, libxml2
#, lockdev
}:

let
  inherit (stdenv.lib)
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "libgphoto2-2.5.10";

  src = fetchurl {
    url = "mirror://sourceforge/gphoto/${name}.tar.bz2";
    sha256 = "8d8668d432ba595c7466442aec2cf553bdf8782ec171291dbc65717c633a4ef2";
  };

  nativeBuildInputs = [
    flex
    gettext
    libtool
  ];

  buildInputs = [
    libexif
    libgd
    libjpeg-turbo_1-4
    libusb
    libxml2
    #lockdev
  ];

  configureFlags = [
    "--disable-gp2ddb"
    "--enable-nls"
    "--enable-rpath"
    "--enable-largefile"
    "--disable-internal-docs"
    "--disable-docs"
    (wtFlag "jpeg" (libjpeg-turbo_1-4 != null) null)
    "--with-camlibs=all"
  ];

  meta = with stdenv.lib; {
    description = "A library for accessing digital cameras";
    homepage = http://www.gphoto.org/proj/libgphoto2/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

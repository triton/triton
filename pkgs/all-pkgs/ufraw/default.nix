{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl

, bzip2
, cfitsio
, exiv2
, gconf
#, gimp
, glib
, gtk_2
, gtkimageview
, jasper
, lcms2
, lensfun
, libjpeg
, libpng
, libtiff

, zlib
}:

# TODO: gimp plugin support

let
  inherit (stdenv.lib)
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "ufraw-0.22";

  src = fetchurl {
    url = "mirror://sourceforge/ufraw/${name}.tar.gz";
    sha256 = "0pm216pg0vr44gwz9vcvq3fsf8r5iayljhf5nis2mnw7wn6d5azp";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    bzip2
    cfitsio
    exiv2
    gconf
    #gimp
    glib
    gtk_2
    gtkimageview
    jasper
    lcms2
    lensfun
    libjpeg
    libpng
    libtiff
  ];

  patches = [
    (fetchTritonPatch {
      rev = "ea148bf1fddfb4909ef0fe3dd0c92ec7b2322877";
      file = "ufraw/ufraw-0.17-cfitsio-automagic.patch";
      sha256 = "d489abaa6da90a46f4b3b23e2e5400c1eeb7d2e5532835df4d5ad244167e7d18";
    })
  ];

  configureFlags = [
    "--enable-openmp"
    "--disable-no-cygwin"
    "--enable-mime"
    "--enable-extras"
    "--enable-dst-correction"
    "--enable-contrast"
    "--disable-interp-none"
    "--disable-valgrind"
    (wtFlag "gtk" (gtk_2 != null) null)
    #(wtFlag "gimp" (gimp != null) null)
    "--without-gimp"
  ];

  meta = with stdenv.lib; {
    description = "Utility to read & manipulate raw images from digital cameras";
    homepage = http://ufraw.sourceforge.net/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

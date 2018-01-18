{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
, lib
, makeWrapper

, bzip2
, cfitsio
, exiv2
, gconf
, gdk-pixbuf
#, gimp
, glib
, gnome-themes-standard
, gtk_2
, gtkimageview
, jasper
, lcms2
, lensfun
, libjpeg
, libpng
, libtiff
, shared-mime-info
, zlib
}:

# TODO: gimp plugin support

let
  inherit (lib)
    boolWt;
in
stdenv.mkDerivation rec {
  name = "ufraw-0.22";

  src = fetchurl {
    url = "mirror://sourceforge/ufraw/ufraw/${name}/${name}.tar.gz";
    sha256 = "0pm216pg0vr44gwz9vcvq3fsf8r5iayljhf5nis2mnw7wn6d5azp";
  };

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
  ];

  buildInputs = [
    bzip2
    cfitsio
    exiv2
    gconf
    #gimp
    glib
    gnome-themes-standard
    gtk_2
    gtkimageview
    jasper
    lcms2
    lensfun
    libjpeg
    libpng
    libtiff
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "ea148bf1fddfb4909ef0fe3dd0c92ec7b2322877";
      file = "ufraw/ufraw-0.17-cfitsio-automagic.patch";
      sha256 = "d489abaa6da90a46f4b3b23e2e5400c1eeb7d2e5532835df4d5ad244167e7d18";
    })
    (fetchTritonPatch {
      rev = "6f754a20df9a80e4ba6221f841261604be6540c5";
      file = "u/ufraw/ufraw-0.22-jasper-automagic.patch";
      sha256 = "d8245cb9c45cc02686885aed1886243a06b028fc284cb5830e5b1f1f1e4d7db2";
    })
    (fetchTritonPatch {
      rev = "6f754a20df9a80e4ba6221f841261604be6540c5";
      file = "u/ufraw/ufraw-0.22-crashfix.patch";
      sha256 = "6beb9bd151924e38f7908d26019c72e66d06bf71a84cde8d7c80ccf8104e3bdb";
    })
    (fetchTritonPatch {
      rev = "6f754a20df9a80e4ba6221f841261604be6540c5";
      file = "u/ufraw/ufraw-0.22-drop_superfluous_abs.patch";
      sha256 = "8818808f8fd75fc6860783ffddbae42b5a2b7da937711cc6c2d482dee8f50702";
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
    "--${boolWt (gtk_2 != null)}-gtk"
    #"--${boolWt (gimp != null)}-gimp"
    "--without-gimp"
  ];

  preFixup = ''
    wrapProgram $out/bin/ufraw \
      --set 'GDK_PIXBUF_MODULE_FILE' '${gdk-pixbuf.loaders.cache}' \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --run "$DEFAULT_GTK2_RC_FILES"
  '';

  meta = with lib; {
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

{ stdenv
, fetchTritonPatch
, fetchurl
, fetchpatch
, which
, gnumake

, bzip2
#, harfbuzz
, libpng
, zlib

/* passthru only */
, glib
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;
in

stdenv.mkDerivation rec {
  name = "freetype-2.6.5";

  src = fetchurl {
    urls = [
      "mirror://savannah/freetype/${name}.tar.bz2"
      "mirror://sourceforge/freetype/${name}.tar.bz2"
    ];
    allowHashOutput = false;
    sha256 = "e20a6e1400798fd5e3d831dd821b61c35b1f9a6465d6b18a53a9df4cf441acf0";
  };

  buildInputs = [
    bzip2
    #harfbuzz
    libpng
    zlib
  ];

  patches = [
    # Patch from Arch Linux:
    # Provide a way to set the default subpixel hinting mode
    # at runtime, without depending on the application to do so.
    (fetchTritonPatch {
      rev = "76504e1325b09e9d214deef685183df37ad78819";
      file = "freetype2/0003-Make-subpixel-hinting-mode-configurable.patch";
      sha256 = "692f26495df74bedab2f0dc14e06d92fa655d633b5c5f48a60991c2970499ebf";
    })
  ];

  postPatch = /* Enable table validation modules */ ''
    sed -i modules.cfg \
      -e 's,# AUX_MODULES += gxvalid,AUX_MODULES += gxvalid,' \
      -e 's,# AUX_MODULES += otvalid,AUX_MODULES += otvalid,'
  '' + /* Enable subpixel rendering */ ''
    sed -i include/freetype/config/ftoption.h \
      -e 's,/* #define FT_CONFIG_OPTION_SUBPIXEL_RENDERING */,#define FT_CONFIG_OPTION_SUBPIXEL_RENDERING,'
  '';

  configureFlags = [
    "--enable-biarch-config"
    "--with-zlib"
    "--with-bzip2"
    "--with-png"
    # Recursive dependency
    "--without-harfbuzz"
    "--without-old-mac-fonts"
    "--without-fsspec"
    "--without-fsref"
    "--without-quickdraw-toolbox"
    "--without-quickdraw-carbon"
    "--without-ats"
  ];

  # https://bugzilla.redhat.com/show_bug.cgi?id=506840
  NIX_CFLAGS_COMPILE = "-fno-strict-aliasing";

  postInstall = glib.flattenInclude;

  doCheck = true;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "58E0 C111 E39F 5408 C5D3  EC76 C1A6 0EAC E707 FDA5";
    };
  };

  meta = with stdenv.lib; {
    description = "A font rendering engine";
    homepage = http://www.freetype.org/;
    license = licenses.gpl2Plus; # or the FreeType License (BSD + advertising clause)
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

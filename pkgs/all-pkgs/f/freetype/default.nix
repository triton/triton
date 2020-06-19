{ stdenv
, fetchurl
, gnumake
, lib
, which

, bzip2
, harfbuzz_lib
, libpng
, zlib

, type
/* passthru only */
, glib
}:

let
  inherit (lib)
    boolWt
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "freetype-2.10.2";

  src = fetchurl {
    urls = [
      "mirror://savannah/freetype/${name}.tar.xz"
      "mirror://sourceforge/freetype/${name}.tar.xz"
    ];
    hashOutput = false;
    sha256 = "1543d61025d2e6312e0a1c563652555f17378a204a61e99928c9fcef030a2d8b";
  };

  buildInputs = [
    bzip2
    libpng
    zlib
  ] ++ optionals (type != "harfbuzz") [
    harfbuzz_lib
  ];

  postPatch = ''
    # Enable table validation modules
    sed -i modules.cfg \
      -e '/AUX_MODULES += gxvalid/ s/#\s//g' \
      -e '/AUX_MODULES += otvalid/ s/#\s//g'

    # Enable subpixel rendering
    sed -i include/freetype/config/ftoption.h \
      -e '/#define FT_CONFIG_OPTION_SUBPIXEL_RENDERING/ s,\(/\*\s\|\*/\),,g'

    # Enable long PCF family names
    sed -i include/freetype/config/ftoption.h \
      -e '/#define PCF_CONFIG_OPTION_LONG_FAMILY_NAMES/ s,\(/\*\s\|\*/\),,g'
  '';

  configureFlags = [
    "--enable-biarch-config"
    "--enable-freetype-config"  # Needed by grub
    "--with-zlib"
    "--with-bzip2"
    "--with-png"
    "--${boolWt (type != "harfbuzz")}-harfbuzz"
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
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "58E0 C111 E39F 5408 C5D3  EC76 C1A6 0EAC E707 FDA5";
      };
    };
  };

  meta = with lib; {
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

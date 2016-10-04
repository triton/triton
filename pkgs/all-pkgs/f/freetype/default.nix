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
  name = "freetype-2.7";

  src = fetchurl {
    urls = [
      "mirror://savannah/freetype/${name}.tar.bz2"
      "mirror://sourceforge/freetype/${name}.tar.bz2"
    ];
    hashOutput = false;
    sha256 = "d6a451f5b754857d2aa3964fd4473f8bc5c64e879b24516d780fb26bec7f7d48";
  };

  buildInputs = [
    bzip2
    #harfbuzz
    libpng
    zlib
  ];

  patches = [
    # XXX: if fontconfig-infinality-ultimate updates to support 2.6.5+
    #      then revert to using their patches, in the meantime
    #      https://github.com/archfan/infinality_bundle, provides
    #      updated versions of the patches.
    (fetchTritonPatch {
      rev = "4a158da85dc6d434cf7a441f3714cde13d0e0d39";
      file = "f/freetype2/0001-Enable-table-validation-modules.patch";
      sha256 = "6d273254fd925d284e5f66e3861eaef69a4393f34872398b2c93af0d5e15d34e";
    })
    (fetchTritonPatch {
      rev = "4a158da85dc6d434cf7a441f3714cde13d0e0d39";
      file = "f/freetype2/0002-infinality-2.7-2016.09.09.patch";
      sha256 = "cde2053ec4d5d31147138bd9775b53280592d6e7c4685747344608c0c7137e67";
    })
  ];

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

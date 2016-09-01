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

, freetype2-infinality-ultimate

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
    # XXX: if fontconfig-infinality-ultimate updates to support 2.6.5+
    #      then revert to using their patches, in the meantime
    #      https://github.com/archfan/infinality_bundle, provides
    #      updated versions of the patches.
    (fetchTritonPatch {
      rev = "3787a34c73fd56e2dc4bf10d1bd28bcba0b0b6ed";
      file = "f/freetype2/0001-Enable-table-validation-modules.patch";
      sha256 = "530bf17009dffa78ebf2222c8cd5fb0ee1ecb3f7e1a7bdaa55e91b0055510514";
    })
    (fetchTritonPatch {
      rev = "3787a34c73fd56e2dc4bf10d1bd28bcba0b0b6ed";
      file = "f/freetype2/0002-infinality-2.6.5-2016.08.18.patch";
      sha256 = "af4238937fd47d6ecf143bd6d7a5e5122b8bffe20967c1b9fd3a6b9147915771";
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

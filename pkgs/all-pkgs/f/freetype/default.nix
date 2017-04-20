{ stdenv
, fetchTritonPatch
, fetchurl
, fetchpatch
, which
, gnumake

, bzip2
, harfbuzz_lib
, libpng
, zlib

, type
/* passthru only */
, glib
}:

let
  inherit (stdenv.lib)
    boolWt
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "freetype-2.7.1";

  src = fetchurl {
    urls = [
      "mirror://savannah/freetype/${name}.tar.bz2"
      "mirror://sourceforge/freetype/${name}.tar.bz2"
    ];
    hashOutput = false;
    sha256 = "3a3bb2c4e15ffb433f2032f50a5b5a92558206822e22bfe8cbe339af4aa82f88";
  };

  buildInputs = [
    bzip2
    libpng
    zlib
  ] ++ optionals (type != "harfbuzz") [
    harfbuzz_lib
  ];

  patches = [
    # XXX: if fontconfig-infinality-ultimate updates to support 2.6.5+
    #      then revert to using their patches, in the meantime
    #      https://github.com/archfan/infinality_bundle, provides
    #      updated versions of the patches.
    (fetchTritonPatch {
      rev = "2d67959be9b13d2c4191cd7cea45ea337e677a7e";
      file = "f/freetype2/0001-Enable-table-validation-modules.patch";
      sha256 = "6d273254fd925d284e5f66e3861eaef69a4393f34872398b2c93af0d5e15d34e";
    })
    (fetchTritonPatch {
      rev = "2d67959be9b13d2c4191cd7cea45ea337e677a7e";
      file = "f/freetype2/0002-infinality-2.7.1-2017.01.11.patch";
      sha256 = "5ac6329d4ffd6d94d9dd76b178fa13ab2fcfadbf2ddaa7ad60bf0bb7632afd69";
    })
  ];

  configureFlags = [
    "--enable-biarch-config"
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

{ stdenv
, fetchurl
, fetchpatch
, which
, gnumake

, bzip2
#, harfbuzz
, libpng
, zlib

, infinality ? true
  , freetype2-infinality-ultimate
, patentEncumbered ? true

, glib /* passthru only */
}:

# NOTE: freetype2-infinality-ultimate must be updated in unison
#       with freetype.

let
  inherit (stdenv.lib)
    optionalString;
in

stdenv.mkDerivation rec {
  name = "freetype-2.6.3";

  src = fetchurl {
    urls = [
      "mirror://savannah/freetype/${name}.tar.bz2"
      "mirror://sourceforge/freetype/${name}.tar.bz2"
    ];
    allowHashOutput = false;
    sha256 = "371e707aa522acf5b15ce93f11183c725b8ed1ee8546d7b3af549863045863a2";
  };

  buildInputs = [
    bzip2
    #harfbuzz
    libpng
    zlib
  ];

  prePatch = optionalString infinality ''
    # freetype2-infinality-ultimate patch naming isn't completely
    # predictable, so build include all patches at build time.
    for i in '${freetype2-infinality-ultimate}/share/freetype2-infinality-ultimate/'*'.patch' ; do
      patches+=" $i"
    done
    echo
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

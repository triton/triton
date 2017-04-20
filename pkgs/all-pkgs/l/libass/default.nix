{ stdenv
, fetchurl
, yasm

, fontconfig
, freetype
, fribidi
, harfbuzz_lib

, rasterizerSupport ? true # Internal rasterizer
, largeTilesSupport ? false # Use larger tiles in the rasterizer
}:

let
  inherit (stdenv.lib)
    boolEn;

  version = "0.13.6";
in
stdenv.mkDerivation rec {
  name = "libass-${version}";

  src = fetchurl {
    url = "https://github.com/libass/libass/releases/download/${version}/"
      + "${name}.tar.xz";
    sha256 = "f8a874d104e3e72e2cc057e5a1710c650b10367486845a26e5ff28ed7a912c2d";
  };

  nativeBuildInputs = [
    yasm
  ];

  buildInputs = [
    fontconfig
    freetype
    fribidi
    harfbuzz_lib
  ];

  configureFlags = [
    "--${boolEn doCheck}-test"
    "--disable-profile"
    "--${boolEn (fontconfig != null)}-fontconfig"
    "--disable-directwrite" # Windows
    "--disable-coretext" # OSX
    "--enable-require-system-font-provider"
    "--${boolEn (harfbuzz_lib != null)}-harfbuzz"
    "--${boolEn (yasm != null)}-asm"
    "--${boolEn rasterizerSupport}-rasterizer"
    "--${boolEn largeTilesSupport}-large-tiles"
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Library for SSA/ASS subtitles rendering";
    homepage = https://github.com/libass/libass;
    license = licenses.isc;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

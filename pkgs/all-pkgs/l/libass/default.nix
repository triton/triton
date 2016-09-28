{ stdenv
, fetchurl
, yasm

, fontconfig
, freetype
, fribidi
, harfbuzz

, rasterizerSupport ? true # Internal rasterizer
, largeTilesSupport ? false # Use larger tiles in the rasterizer
}:

let
  inherit (stdenv.lib)
    boolEn;

  version = "0.13.3";
in
stdenv.mkDerivation rec {
  name = "libass-${version}";

  src = fetchurl {
    url = "https://github.com/libass/libass/releases/download/${version}/"
      + "${name}.tar.xz";
    sha256 = "a641b653d7c9f2f3b9d6a5e5a906a004ac3e110487ad485d9dd029e944bb3f6d";
  };

  nativeBuildInputs = [
    yasm
  ];

  buildInputs = [
    fontconfig
    freetype
    fribidi
    harfbuzz
  ];

  configureFlags = [
    "--${boolEn doCheck}-test"
    "--disable-profile"
    "--${boolEn (fontconfig != null)}-fontconfig"
    "--disable-directwrite" # Windows
    "--disable-coretext" # OSX
    "--enable-require-system-font-provider"
    "--${boolEn (harfbuzz != null)}-harfbuzz"
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

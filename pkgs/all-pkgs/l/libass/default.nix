{ stdenv
, fetchurl
, nasm

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

  version = "0.13.7";
in
stdenv.mkDerivation rec {
  name = "libass-${version}";

  src = fetchurl {
    url = "https://github.com/libass/libass/releases/download/${version}/"
      + "${name}.tar.xz";
    sha256 = "7065e5f5fb76e46f2042a62e7c68d81e5482dbeeda24644db1bd066e44da7e9d";
  };

  nativeBuildInputs = [
    nasm
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
    "--${boolEn (nasm != null)}-asm"
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

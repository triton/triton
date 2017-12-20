{ stdenv
, fetchurl
, nasm

, fontconfig
, freetype
, fribidi
, harfbuzz_lib

, largeTilesSupport ? false # Use larger tiles in the rasterizer
}:

let
  inherit (stdenv.lib)
    boolEn;

  version = "0.14.0";
in
stdenv.mkDerivation rec {
  name = "libass-${version}";

  src = fetchurl {
    url = "https://github.com/libass/libass/releases/download/${version}/"
      + "${name}.tar.xz";
    sha256 = "881f2382af48aead75b7a0e02e65d88c5ebd369fe46bc77d9270a94aa8fd38a2";
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
    "--${boolEn largeTilesSupport}-large-tiles"
  ];

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

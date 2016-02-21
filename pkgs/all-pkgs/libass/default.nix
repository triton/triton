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

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "libass-${version}";
  version = "0.13.2";

  src = fetchurl {
    url = "https://github.com/libass/libass/releases/download/${version}/" +
          "${name}.tar.xz";
    sha256 = "1kpsw4zw95v4cjvild9wpk73dzavn1khsm3bm32kcz6amnkd166n";
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
    (enFlag "test" doCheck null)
    "--disable-profile"
    (enFlag "fontconfig" (fontconfig != null) null)
    "--disable-directwrite" # Windows
    "--disable-coretext" # OSX
    "--enable-require-system-font-provider"
    (enFlag "harfbuzz" (harfbuzz != null) null)
    (enFlag "asm" (yasm != null) null)
    (enFlag "rasterizer" rasterizerSupport null)
    (enFlag "large-tiles" largeTilesSupport null)
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

{ stdenv, fetchurl, pkgconfig, yasm
, freetype, fribidi
, encaSupport ? true, enca ? null # enca support
, fontconfigSupport ? true, fontconfig ? null # fontconfig support
, harfbuzzSupport ? true, harfbuzz ? null # harfbuzz support
, rasterizerSupport ? false # Internal rasterizer
, largeTilesSupport ? false # Use larger tiles in the rasterizer
}:

assert encaSupport -> enca != null;
assert fontconfigSupport -> fontconfig != null;
assert harfbuzzSupport -> harfbuzz != null;

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "libass-${version}";
  version = "0.13.1";

  src = fetchurl {
    url = "https://github.com/libass/libass/releases/download/${version}/${name}.tar.xz";
    sha256 = "1rrz6is2blx8jqyydcz71y2f5f948blgx14jzi3an756fqc6p8sa";
  };

  configureFlags = [
    (mkEnable encaSupport       "enca"        null)
    (mkEnable fontconfigSupport "fontconfig"  null)
    (mkEnable harfbuzzSupport   "harfbuzz"    null)
    (mkEnable rasterizerSupport "rasterizer"  null)
    (mkEnable largeTilesSupport "large-tiles" null)
  ];

  nativeBuildInputs = [ pkgconfig yasm ];

  buildInputs = [ freetype fribidi ]
    ++ optional encaSupport enca
    ++ optional fontconfigSupport fontconfig
    ++ optional harfbuzzSupport harfbuzz;

  meta = {
    description = "Portable ASS/SSA subtitle renderer";
    homepage    = https://github.com/libass/libass;
    license     = licenses.isc;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ codyopel urkud ];
    repositories.git = git://github.com/libass/libass.git;
  };
}

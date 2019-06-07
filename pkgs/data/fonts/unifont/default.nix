{ stdenv
, fetchurl

, xorg
}:

stdenv.mkDerivation rec {
  name = "unifont-12.1.02";

  buildInputs = [
    xorg.mkfontdir
    xorg.mkfontscale
  ];

  phases = [
    "installPhase"
  ];

  installPhase =
    let
      unifont_pcf = fetchurl {
        url = "http://unifoundry.com/pub/unifont/${name}/font-builds/${name}.pcf.gz";
        multihash = "QmcC7bSKatQwJXUR7rrZBPr4YidHaa7MzL91NVi91s1TME";
        sha256 = "04d652be1e28a6d464965c75c71ac84633085cd0960c2687466651c34c94bd89";
      };

      unifont_ttf = fetchurl {
        url = "http://unifoundry.com/pub/unifont/${name}/font-builds/${name}.ttf";
        multihash = "QmUVsDN4tADFKCzuadUFFc9vREBPGJjJ82p6iDbNTp4F5L";
        sha256 = "da4961540b9d02e01fb8755924db730db233c360b20ee321fda8ab7d0b9ca549";
      };
    in ''
      mkdir -pv $out/share/fonts $out/share/fonts/truetype
      cp -v ${unifont_pcf} $out/share/fonts/unifont.pcf.gz
      cp -v ${unifont_ttf} $out/share/fonts/truetype/unifont.ttf
      cd $out/share/fonts
      mkfontdir
      mkfontscale
    '';

  meta = with stdenv.lib; {
    description = "Unicode font for Base Multilingual Plane";
    homepage = http://unifoundry.com/unifont.html;
    # Basically GPL2+ with font exception.
    license = http://unifoundry.com/LICENSE.txt;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}

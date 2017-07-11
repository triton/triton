{ stdenv
, fetchurl

, xorg
}:

stdenv.mkDerivation rec {
  name = "unifont-10.0.04";

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
        url = "http://unifoundry.com/pub/${name}/font-builds/${name}.pcf.gz";
        multihash = "QmYEtZb25fbFZveFKAFKP93bMxDR97KbVWhwSCAb297u49";
        sha256 = "c270336dfd05b1d9ef701cfd0d17c23fb158d2bbf48f08a875ab4922cdb542d6";
      };

      unifont_ttf = fetchurl {
        url = "http://unifoundry.com/pub/${name}/font-builds/${name}.ttf";
        multihash = "QmVXEam23TPvyuLPa3RmuwDGauCH3JenzWVXRsJMfM8sfY";
        sha256 = "4264d367a5793c06d8a79e90634ab003e59269f7e80bca51f6daa0ce90fbe962";
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

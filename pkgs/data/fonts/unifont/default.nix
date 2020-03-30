{ stdenv
, fetchurl

, xorg
}:

stdenv.mkDerivation rec {
  name = "unifont-13.0.01";

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
        url = "mirror://gnu/unifont/${name}/${name}.pcf.gz";
        sha256 = "a847a7a6332c024865889b21011a248a2ef023c99be104b18c8c846201f8ef17";
      };

      unifont_ttf = fetchurl {
        url = "mirror://gnu/unifont/${name}/${name}.ttf";
        sha256 = "8f3d8b12841ad564ef649c1c302248efa8c53dd40b603c9ad1335d58e269ab78";
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

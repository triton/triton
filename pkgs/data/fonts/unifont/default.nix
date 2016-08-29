{ stdenv, fetchurl, xorg }:

stdenv.mkDerivation rec {
  name = "unifont-9.0.02";

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
        multihash = "Qmf7skRRpT8UXnEBSKGGahRKZDMRxecey4noUEtV9vzwQu";
        sha256 = "29ac5e89b6f40537a8bd5f1460d3927cff8cfeb37975eddf8f26b85e975ca025";
      };

      unifont_ttf = fetchurl {
        url = "http://unifoundry.com/pub/${name}/font-builds/${name}.ttf";
        multihash = "QmU8DRxEN2SqwR8Vki5RNPdX4Wt9B5KkV28T1DCtpFFhLf";
        sha256 = "753a9cb25da2f4e52df96f8b6ee9246c1b130cdc8ee3beaad6227b771f294291";
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

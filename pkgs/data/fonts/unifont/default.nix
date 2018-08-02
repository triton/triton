{ stdenv
, fetchurl

, xorg
}:

stdenv.mkDerivation rec {
  name = "unifont-11.0.01";

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
        multihash = "QmXFGvsSo3dLS159fLD4jnjyL5XV7x1J9VFc7Kegdfh7np";
        sha256 = "610bed938dfbe5cdfe068c86c0f33b82b193b6606078a739746af81bc5c7780d";
      };

      unifont_ttf = fetchurl {
        url = "http://unifoundry.com/pub/unifont/${name}/font-builds/${name}.ttf";
        multihash = "QmXaUpwGb6D7BhSruLnd7nVuvkcRerWECdXdgETCxBXyD9";
        sha256 = "91cf5d17cb7f87e4a5933c3c72e119a43b0ab7bd1892063c240a1849a075d60e";
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

{ stdenv
, fetchurl

, xorg
}:

stdenv.mkDerivation rec {
  name = "unifont-9.0.06";

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
        multihash = "QmQ8rcmpvnSHTgrFLq8VhvL88i1jQfBEczZHbX1aPPapsU";
        sha256 = "6d23e82ea3fd3d79849d675c0c30129b62a3973a83b4cdc05f9994efef773b86";
      };

      unifont_ttf = fetchurl {
        url = "http://unifoundry.com/pub/${name}/font-builds/${name}.ttf";
        multihash = "QmbKttQAQBgfAdWHKgXjXT6kKgDLrzr4sK3BDH94qM62oY";
        sha256 = "e217fbf24ac1ba3f028ed937b30b6c27f31fd1288857ca0fb0b11100637c2665";
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

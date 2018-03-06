{ stdenv
, lib
, fetchFromGitHub

, fontconfig
, freetype
, giflib
, imlib2
, libexif
, libx11
, libxft
, libxrender
, xorgproto
}:

let
  version = "24";
in
stdenv.mkDerivation {
  name = "sxiv-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "muennich";
    repo = "sxiv";
    rev = "v${version}";
    sha256 = "fc552a676d6448a3e4fe1eb1323861b4cb5875fd3a824ea6fd129af1dc69c5c1";
  };

  buildInputs = [
    fontconfig
    freetype
    giflib
    imlib2
    libexif
    libx11
    libxft
    libxrender
    xorgproto
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

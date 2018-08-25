{ stdenv
, fetchurl
, lib

, fontconfig
, fontforge
, perlPackages
, unicode-character-database
}:

let
  version = "2.37";

  version_ = lib.replaceChars ["."] ["_"] version;
in
stdenv.mkDerivation rec {
  name = "dejavu-fonts-${version}";

  src = fetchurl {
    urls = [
      "https://github.com/dejavu-fonts/dejavu-fonts/releases/download/version_${version_}/${name}.tar.bz2"
      "mirror://sourceforge/dejavu/${name}.tar.bz2"
    ];
    sha256 = "4b21c5203f792343d5e90ab1cb0cf07e99887218abe3d83cd9a98cea9085e799";
  };

  #fontconfig is needed only for fc-lang (?)
  buildInputs = [
    fontconfig
    fontforge
    perlPackages.perl
    perlPackages.FontTTF
    unicode-character-database
  ];

  postPatch = ''
    patchShebangs ./scripts/
  '';

  preBuild = ''
    local FC_LANG_PATH
    tar xfv ${fontconfig.src} --wildcards '*/fc-lang'
    FC_LANG_PATH="$PWD"/fontconfig-*/fc-lang

    makeFlagsArray+=("FC-LANG=$FC_LANG_PATH")
  '';

  buildFlags = [
    "full"
    "sans"
  ];

  makeFlags = [
    "BUILDDIR=ttf"
    "BLOCKS=${unicode-character-database}/share/unicode-character-database/Blocks.txt"
    "UNICODEDATA=${unicode-character-database}/share/unicode-character-database/UnicodeData.txt"
  ];

  installPhase = ''
    for i in $(find -name '*.ttf') ; do
      install -D -m 644 -v "$i" "$out/share/fonts/truetype/$(basename $i)"
    done;
  '';

  meta = with lib; {
    description = "A typeface family based on the Bitstream Vera fonts";
    homepage = http://dejavu-fonts.org/;
    license = licenses.free; # BitstreamVera & public domain
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

{ lib
, runCommand
, writeText

, fontconfig
, fontDirectories
}:

let
  inherit (lib)
    concatStringsSep;
in
runCommand "fc-cache" rec {
  buildInputs = [
    fontconfig
  ];

  passAsFile = [
    "fontDirs"
  ];

  fontDirs = ''
    <!-- Font directories -->
    ${concatStringsSep "\n"
      (map (font: "<dir>${font}</dir>") fontDirectories)}
  '';
}
''
  export FONTCONFIG_FILE=$(pwd)/fonts.conf

  cat > fonts.conf << EOF
  <?xml version='1.0'?>
  <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
  <fontconfig>
    <include>${fontconfig}/etc/fonts/fonts.conf</include>
    <cachedir>$out</cachedir>
  EOF
  cat "$fontDirsPath" >> fonts.conf
  echo "</fontconfig>" >> fonts.conf

  mkdir -pv $out
  fc-cache -sv
''

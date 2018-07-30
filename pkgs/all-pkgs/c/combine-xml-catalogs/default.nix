{ stdenv
, libxml2
}:

derivations:
let
  inherit (stdenv.lib)
    flip
    concatMapStrings;
in
stdenv.mkDerivation {
  name = "combined-xml-catalog";

  nativeBuildInputs = [
    libxml2
  ];

  preferLocalBuild = true;

  buildCommand = ''
    xmlcatalog --noout --create "$out"
  '' + flip concatMapStrings derivations (d: ''
    for c in $(find "${d}" -name catalog.xml); do
      xmlcatalog --noout --add nextCatalog "$c" "" "$out"
    done
  '');
}

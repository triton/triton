{ stdenv
, fetchurl
, lib
}:

let
  version = "1.7";
in
stdenv.mkDerivation rec {
  name = "acpi-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/acpiclient/acpiclient/${version}/${name}.tar.gz";
    sha256 = "01ahldvf0gc29dmbd5zi4rrnrw2i1ajnf30sx2vyaski3jv099fp";
  };

  meta = with lib; {
    description = "Show battery status and other ACPI information";
    homepage = http://sourceforge.net/projects/acpiclient/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

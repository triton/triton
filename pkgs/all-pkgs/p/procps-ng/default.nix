{ stdenv
, fetchurl

, ncurses
}:

let
  version = "3.3.12";
in
stdenv.mkDerivation {
  name = "procps-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/procps-ng/procps-ng-${version}.tar.xz";
    multihash = "QmRgtzxS6QizqhxMKg4c467ULX53fSnc13pFkPPW6vTG8H";
    sha256 = "6ed65ab86318f37904e8f9014415a098bec5bc53653e5d9ab404f95ca5e1a7d4";
  };

  buildInputs = [
    ncurses
  ];

  makeFlags = [
    "usrbin_execdir=$(out)/bin"
  ];

  meta = with stdenv.lib; {
    homepage = http://sourceforge.net/projects/procps-ng/;
    description = "Utilities that give information about processes using the /proc filesystem";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

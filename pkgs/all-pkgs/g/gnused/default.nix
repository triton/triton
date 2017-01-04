{ stdenv
, fetchurl
, perl
}:

let
  version = "4.3";
in
stdenv.mkDerivation rec {
  name = "gnused-${version}";

  src = fetchurl {
    url = "mirror://gnu/sed/sed-${version}.tar.xz";
    hashOutput = false;
    sha256 = "47c20d8841ce9e7b6ef8037768aac44bc2937fff1c265b291c824004d56bd0aa";
  };

  nativeBuildInputs = [
    perl
  ];

  postPatch = ''
    patchShebangs build-aux/help2man
  '';

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/sed/;
    description = "GNU sed, a batch stream editor";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

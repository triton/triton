{ stdenv
, fetchurl

, lzip
}:

stdenv.mkDerivation rec {
  name = "ddrescue-1.20";

  src = fetchurl {
    url = "mirror://gnu/ddrescue/${name}.tar.lz";
    sha256 = "1gb0ak2c47nass7qdf9pnfrshcb38c318z1fx5v5v1k7l6qr7yc3";
  };

  nativeBuildInputs = [
    lzip
  ];

  meta = with stdenv.lib; {
    description = "GNU ddrescue, a data recovery tool";
    homepage = http://www.gnu.org/software/ddrescue/ddrescue.html;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux
  };
}

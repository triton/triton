{ stdenv, fetchurl, python, boost, libgsf }:

stdenv.mkDerivation rec {
  name = "libpst-0.6.66";

  src = fetchurl {
    url = "http://www.five-ten-sg.com/libpst/packages/${name}.tar.gz";
    sha256 = "0whzgrky1b015czg9f5mk8zpz1mvip3ifzp24nfis291v0wrkd4j";
  };

  nativeBuildInputs = [ python ];
  buildInputs = [ boost libgsf ];

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = http://www.five-ten-sg.com/libpst/;
    description = "A library to read PST (MS Outlook Personal Folders) files";
    license = licenses.gpl2;
  };
}

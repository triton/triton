{ stdenv, fetchurl, autoreconfHook, boost, python, libgsf
, bzip2, xmlto, gettext, imagemagick, doxygen }:

stdenv.mkDerivation rec {
  name = "libpst-0.6.66";

  src = fetchurl {
    url = "http://www.five-ten-sg.com/libpst/packages/${name}.tar.gz";
    sha256 = "0whzgrky1b015czg9f5mk8zpz1mvip3ifzp24nfis291v0wrkd4j";
  };

  nativeBuildInputs = [ autoreconfHook python xmlto gettext doxygen ];
  buildInputs = [ boost libgsf bzip2 imagemagick ];

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = http://www.five-ten-sg.com/libpst/;
    description = "A library to read PST (MS Outlook Personal Folders) files";
    license = licenses.gpl2;
  };
}

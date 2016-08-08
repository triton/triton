{ stdenv
, fetchurl
, coreutils
}:

stdenv.mkDerivation rec {
  name = "diffutils-3.3";

  src = fetchurl {
    url = "mirror://gnu/diffutils/${name}.tar.xz";
    sha256 = "1761vymxbp4wb5rzjvabhdkskk95pghnn67464byvzb5mfl8jpm2";
  };

  # We need to directly reference coreutils, otherwise the
  # output depends on the bootstrap.
  buildInputs = [
    coreutils
  ];

  meta = with stdenv.lib; {
    description = "Commands for showing the differences (diff) between files";
    homepage = http://www.gnu.org/software/diffutils/diffutils.html;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

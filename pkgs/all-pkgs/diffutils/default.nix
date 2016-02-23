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

  # We need to directly reference coreutils
  # Otherwise the output depends on the bootstrap
  buildInputs = [
    coreutils
  ];

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/diffutils/diffutils.html;
    description = "Commands for showing the differences between files (diff, cmp, etc.)";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

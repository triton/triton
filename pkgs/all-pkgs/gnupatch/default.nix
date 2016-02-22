{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "gnupatch-${version}";
  version = "2.7.5";

  src = fetchurl {
    url = "mirror://gnu/patch/patch-${version}.tar.xz";
    sha256 = "16d2r9kpivaak948mxzc0bai45mqfw73m113wrkmbffnalv1b5gx";
  };

  meta = with stdenv.lib; {
    description = "GNU Patch, a program to apply differences to files";
    homepage = http://savannah.gnu.org/projects/patch;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

{ stdenv
, fetchurl
}:

let
  version = "0.7.0";
in
stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/project/filezilla/libfilezilla/${version}/"
      + "${name}.tar.bz2";
    sha256 = "276528e4aafca9c89dc5ed6dd047f2db1aa72aa3f2c564eb3fd6cf9f594bab1d";
  };

  meta = with stdenv.lib; {
    homepage = "https://lib.filezilla-project.org/index.php";
    license = licenses.lpgl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

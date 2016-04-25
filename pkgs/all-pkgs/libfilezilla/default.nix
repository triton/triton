{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";
  version = "0.5.0";

  src = fetchurl {
    url = "mirror://sourceforge/project/filezilla/libfilezilla/${version}/${name}.tar.bz2";
    sha256 = "8c6a1af13113bbb78e1c66ebbbffa84c0f0ee243c0789e9b92f8e11fcb84c51d";
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

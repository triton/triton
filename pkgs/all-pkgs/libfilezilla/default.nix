{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";
  version = "0.4.0.1";

  src = fetchurl {
    url = "mirror://sourceforge/project/filezilla/libfilezilla/${version}/${name}.tar.bz2";
    sha256 = "1ldiyhjv4jg2jyj3d56mlgyj9lx0qkf1857wvsy51lp9aj96h0v0";
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

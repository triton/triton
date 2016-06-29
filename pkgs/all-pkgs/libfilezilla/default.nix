{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";
  version = "0.5.3";

  src = fetchurl {
    url = "mirror://sourceforge/project/filezilla/libfilezilla/${version}/${name}.tar.bz2";
    multihash = "Qmcfd2WRjaw9jVMtpcjwPxhSDbFPYMGoqTAvag5Zojq4ki";
    sha256 = "11303c1581073aaf6aa8b5aa0913fb1fc4cd96e1563cbedaa01e5914af68e917";
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

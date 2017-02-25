{ stdenv
, fetchurl
}:

let
  version = "0.9.1";
in
stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";

  src = fetchurl {
    urls = [
      "https://download.filezilla-project.org/libfilezilla/${name}.tar.bz2"
      "mirror://sourceforge/filezilla/libfilezilla/${version}/${name}.tar.bz2"
    ];
    sha256 = "18b2391771f330cccab2c55a66197b9098f236e616f26f86326795b900913b1a";
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

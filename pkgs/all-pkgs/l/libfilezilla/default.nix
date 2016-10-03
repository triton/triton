{ stdenv
, fetchurl
}:

let
  version = "0.7.1";
in
stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/filezilla/libfilezilla/${version}/${name}.tar.bz2";
    sha256 = "d95d2db75e523462c3f4b72b663b395dfe988cb71c3abef609f794a155a6ddd3";
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

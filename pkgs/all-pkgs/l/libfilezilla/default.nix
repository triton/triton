{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";
  version = "0.6.1";

  src = fetchurl {
    url = "mirror://sourceforge/project/filezilla/libfilezilla/${version}/${name}.tar.bz2";
    multihash = "Qmb7k9Ly992SmbRJqKfyWimGKSb6dzfnRgMKcrjfYyYALb";
    sha256 = "73c3ada6f9c5649abd93e6a3e7ecc6682d4f43248660b5506918eab76a7b901b";
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

{ stdenv
, fetchurl
}:

let
  version = "0.13.0";
in
stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";

  src = fetchurl {
    url = "mirror://filezilla/libfilezilla/${name}.tar.bz2";
    sha256 = "ffca3c40dbe729dfc9389034f420809dec1b6f2674dc2cd39dc7edfcc59f686a";
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

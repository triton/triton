{ stdenv
, fetchurl
}:

let
  version = "0.8.0";
in
stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";

  src = fetchurl {
    urls = [
      "https://download.filezilla-project.org/libfilezilla/${name}.tar.bz2"
      "mirror://sourceforge/filezilla/libfilezilla/${version}/${name}.tar.bz2"
    ];
    sha256 = "0bee16be8d68d3b393a914458a586b4c684e781f2dcc9d287ce60129dc20015f";
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

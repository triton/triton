{ stdenv
, fetchurl
}:

let
  version = "0.9.0";
in
stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";

  src = fetchurl {
    urls = [
      "https://download.filezilla-project.org/libfilezilla/${name}.tar.bz2"
      "mirror://sourceforge/filezilla/libfilezilla/${version}/${name}.tar.bz2"
    ];
    sha256 = "41d02b3eb54be1b1fdab89104a28a47fb654465a8d9ad00446c221a27bd9800c";
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

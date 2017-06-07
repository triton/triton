{ stdenv
, fetchurl
}:

let
  version = "0.9.2";
in
stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";

  src = fetchurl {
    urls = [
      "https://download.filezilla-project.org/libfilezilla/${name}.tar.bz2"
      "mirror://sourceforge/filezilla/libfilezilla/${version}/${name}.tar.bz2"
    ];
    sha256 = "c162e8a23555b3bbc707cf240b0b4122ea2975d6d8b10744325b968f656b3be3";
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

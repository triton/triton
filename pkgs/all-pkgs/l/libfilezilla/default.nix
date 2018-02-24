{ stdenv
, fetchurl
}:

let
  version = "0.12.1";
in
stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";

  src = fetchurl {
    url = "https://download.filezilla-project.org/libfilezilla/${name}.tar.bz2";
    multihash = "QmZBXEMeYWkPUBZTUyzoHBj3sfQ1QzyqJYv5VGfTXfnp7N";
    sha256 = "60efc9455e022785d432f7a76390dd2d1d92101a65aef1f176a382d604a978bd";
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

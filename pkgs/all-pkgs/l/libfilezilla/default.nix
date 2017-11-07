{ stdenv
, fetchurl
}:

let
  version = "0.11.1";
in
stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";

  src = fetchurl {
    url = "https://download.filezilla-project.org/libfilezilla/${name}.tar.bz2";
    multihash = "QmX5zfiEEXw4ViQoswDk7LtDBF6hLxYNTw48iqx7RB7T3c";
    sha256 = "ecbaa674c0ad0b63df842b8cde17935a497dd58c3749baa281c67cf5878e64f7";
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

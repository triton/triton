{ stdenv
, fetchurl
}:

let
  version = "0.10.1";
in
stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";

  src = fetchurl {
    url = "https://download.filezilla-project.org/libfilezilla/${name}.tar.bz2";
    multihash = "QmTXdsWMoXHu5vAAGFxdJ4XSZmbxr2z6K35iaTVHvwzwHg";
    sha256 = "a097536689f92320f8ee03eed68fe0b82457a53a7f4d287d7c03f60bc16a29fa";
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

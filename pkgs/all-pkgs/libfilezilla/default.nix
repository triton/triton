{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";
  version = "0.5.1";

  src = fetchurl {
    url = "mirror://sourceforge/project/filezilla/libfilezilla/${version}/${name}.tar.bz2";
    multihash = "QmfK7LkjptmaAEqKX6UgFFhHRKb5hSgh11rFR97Tjkk5GV";
    sha256 = "585b58eecc43f3803a3f1b1ee69dce7b57bae5a49d85514044a7c95da299b7f9";
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

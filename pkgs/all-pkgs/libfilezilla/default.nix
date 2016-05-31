{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";
  version = "0.5.2";

  src = fetchurl {
    url = "mirror://sourceforge/project/filezilla/libfilezilla/${version}/${name}.tar.bz2";
    multihash = "QmWXG5MWeHfsnYhG7HTmhxGN3URVwdWvcqNdVuEGKbfqNh";
    sha256 = "2beacbbd00a14c3be035c593278604f146e0268c5f5d58c95957121b6e879c80";
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

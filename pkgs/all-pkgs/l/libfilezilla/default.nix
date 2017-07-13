{ stdenv
, fetchurl
}:

let
  version = "0.10.0";
in
stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";

  src = fetchurl {
    url = "https://download.filezilla-project.org/libfilezilla/${name}.tar.bz2";
    multihash = "QmV8T7MFeGDpLih2pPRDZGWJmZPQBW8tJQtvkpQWRBybuK";
    sha256 = "bd10176c44f421a20c92c66d85a7a277dcc0d1c4b57cf20b7b6ba24cb4493382";
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

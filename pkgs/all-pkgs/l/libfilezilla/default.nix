{ stdenv
, fetchurl
}:

let
  version = "0.11.0";
in
stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";

  src = fetchurl {
    url = "https://download.filezilla-project.org/libfilezilla/${name}.tar.bz2";
    multihash = "QmYpcRPzLs6SqJuFHmFNFrdKbj4y4QtarfKU1ufPZpdNX7";
    sha256 = "cc7467241c8905de98773b414ce445d6f9ff3bf3105f2d16cecab76404879ed0";
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

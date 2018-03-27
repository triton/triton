{ stdenv
, fetchurl
, lib
}:

let
  version = "0.4.8";
in
stdenv.mkDerivation rec {
  name = "poppler-data-${version}";

  src = fetchurl {
    url = "https://poppler.freedesktop.org/${name}.tar.gz";
    multihash = "QmdQTem2g89hfU7ZkHx8uy9CfQsWbZSMsT9uowfmbcuxTk";
    sha256 = "1096a18161f263cccdc6d8a2eb5548c41ff8fcf9a3609243f1b6296abdf72872";
  };
  
  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
, lib

, openssl
, readline
}:

stdenv.mkDerivation rec {
  name = "socat-1.7.3.3";

  src = fetchurl {
    url = "http://www.dest-unreach.org/socat/download/${name}.tar.bz2";
    multihash = "QmSVx8mHJMdfiHXh6gYE6GeHW3BhWb5ZB5gujFrMQcwoxv";
    sha256 = "0dd63ffe498168a4aac41d307594c5076ff307aa0ac04b141f8f1cec6594d04a";
  };
  
  buildInputs = [
    openssl
    readline
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

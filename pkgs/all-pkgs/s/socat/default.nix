{ stdenv
, fetchurl
, lib

, openssl
, readline
}:

stdenv.mkDerivation rec {
  name = "socat-1.7.3.4";

  src = fetchurl {
    url = "http://www.dest-unreach.org/socat/download/${name}.tar.bz2";
    multihash = "QmTbLx3SsQahGwcDBdaLXjoVFy5xhvMw7DJpLh73D9VyTm";
    sha256 = "972374ca86f65498e23e3259c2ee1b8f9dbeb04d12c2a78c0c9b5d1cb97dfdfc";
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

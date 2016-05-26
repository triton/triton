{ stdenv
, fetchurl

, zlib
}:

stdenv.mkDerivation rec {
  name = "kyotocabinet-1.2.76";

  src = fetchurl {
    url = "http://fallabs.com/kyotocabinet/pkg/${name}.tar.gz";
    multihash = "QmaCHam4Ct9TJMYtq56ZAKeWYhxTTn9NuBC2pKyQZdjyaA";
    sha256 = "0g6js20x7vnpq4p8ghbw3mh9wpqksya9vwhzdx6dnlf354zjsal1";
  };

  buildInputs = [
    zlib
  ];

  CXXFLAGS = "-std=gnu++98";

  meta = with stdenv.lib; {
    homepage = http://fallabs.com/kyotocabinet;
    description = "a library of routines for managing a database";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
, lib

, libsndfile
}:

stdenv.mkDerivation rec {
  name = "vamp-plugin-sdk-2.7.1";

  src = fetchurl {
    # Upstream does not use structured URLs.
    url = "http://www.vamp-plugins.org/develop.html";
    name = "${name}.tar.gz";
    multihash = "Qmbksn3uBKxAZ27mPfq7MAC1cA7hmA8VHJENRB98yjxxZT";
    hashOutput = false;
    sha256 = "c6fef3ff79d2bf9575ce4ce4f200cbf219cbe0a21cfbad5750e86ff8ae53cb0b";
  };

  buildInputs = [
    libsndfile
  ];

  meta = with lib; {
    description = "Audio processing plugin system";
    homepage = http://sourceforge.net/projects/vamp;
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}

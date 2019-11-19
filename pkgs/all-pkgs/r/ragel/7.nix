{ stdenv
, fetchurl
, lib

, colm_0-13
, kelbt
}:

stdenv.mkDerivation rec {
  name = "ragel-7.0.0.12";

  src = fetchurl {
    url = "http://www.colm.net/files/ragel/${name}.tar.gz";
    multihash = "QmYuwGvJA4jUMeNzc2q9KxBtarHkVwT2m7rWAicSd1xAEH";
    hashOutput = false;
    sha256 = "3999ef97fb108b39d11d9b96986f5e05c74bd95de8dd474301d86c5aca887a74";
  };

  nativeBuildInputs = [
    colm_0-13.bin
    kelbt.bin
  ];

  buildInputs = [
    colm_0-13.dev
  ];

  postInstall = ''
    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"

    mkdir -p "$lib"/lib
    mv "$dev"/lib/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "man"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30";
      };
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

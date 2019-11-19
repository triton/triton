{ stdenv
, fetchurl
, lib

, channel
}:

let
  inherit (lib)
    optionals
    optionalString;

  channels = {
    "0.12" = {
      version = "0.12.0";
      multihash = "QmW3NUbTM5Ymzyw74hBDr2NmJdbPtyb7xh5eHBBvJkcQCK";
      sha256 = "7b545d74bd139f5c622975d243c575310af1e4985059a1427b6fdbb1fb8d6e4d";
    };
    "0.13" = {
      version = "0.13.0.7";
      multihash = "QmbP5qzdsB1zMcgy4CmzbocWv6oSakNzUHz1qSqXs8z4W8";
      sha256 = "e43fa328ad7672f485848bf4f40ae498a1925ce5199f2d94e4828e13628ee638";
    };
  };

  inherit (channels."${channel}")
    version
    multihash
    sha256;
in
stdenv.mkDerivation rec {
  name = "colm-${version}";

  src = fetchurl {
    url = "http://www.colm.net/files/colm/${name}.tar.gz";
    hashOutput = false;
    inherit
      multihash
      sha256;
  };

  postPatch = ''
    sed -i 's,PREFIX,"/no-such-path",g' src/main.cc
  '';

  postInstall = ''
    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"
  '' + optionalString (channel == "0.13") ''
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
  ] ++ optionals (channel == "0.13") [
    "lib"
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

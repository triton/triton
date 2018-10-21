{ stdenv
, makeWrapper
, fetchurl
, lib

, curl
, imlib2
, libexif
, libjpeg
, libpng
, libx11
, libxinerama
, libxt
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "feh-2.28";

  src = fetchurl {
    url = "https://feh.finalrewind.org/${name}.tar.bz2";
    multihash = "QmeP5cQEnBcToZninaDu1ejnCLYyx7uCU3Yiq1TmfDTq3J";
    hashOutput = false;
    sha256 = "13d22d7c5fe5057612ce3df88857aee89fcab9c8cd6fd4f95a42fe6bf851d3d9";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    curl
    imlib2
    libexif
    libpng
    libx11
    libxinerama
    libxt
    xorgproto
  ];

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "exif=1"
    )
  '';

  postInstall = ''
    wrapProgram "$out/bin/feh" \
      --prefix PATH : "${libjpeg}/bin" \
      --add-flags '--theme=feh'
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrl = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "781B B707 1C6B F648 EAEB  08A1 100D 5BFB 5166 E005";
      };
    };
  };

  meta = with lib; {
    description = "A light-weight image viewer";
    homepage = https://feh.finalrewind.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

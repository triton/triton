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
  name = "feh-3.1.2";

  src = fetchurl {
    url = "https://feh.finalrewind.org/${name}.tar.bz2";
    multihash = "QmYdmPHHLzCAvxYTjfyVzN4YeZhDYN7xN4nwXNtGDPBbAT";
    hashOutput = false;
    sha256 = "6a36d0503507661b8855b6f7e5b01ca6d7119a8f3771936062cf00935fa65062";
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

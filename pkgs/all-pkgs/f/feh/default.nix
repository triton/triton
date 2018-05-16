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
  name = "feh-2.26.2";

  src = fetchurl {
    url = "https://feh.finalrewind.org/${name}.tar.bz2";
    multihash = "QmRuarYuPPqjt74Nquc3AuDiEELoePxCSpXN7j51FiF7B6";
    hashOutput = false;
    sha256 = "6352fff798a29a731006be08e1321468202d03547434b1b0b958cb504b2b161e";
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
      pgpsigUrl = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "781B B707 1C6B F648 EAEB  08A1 100D 5BFB 5166 E005";
      inherit (src) urls outputHash outputHashAlgo;
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

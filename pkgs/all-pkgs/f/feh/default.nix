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
, xproto
}:

stdenv.mkDerivation rec {
  name = "feh-2.22.2";

  src = fetchurl {
    url = "https://feh.finalrewind.org/${name}.tar.bz2";
    multihash = "QmRcKD8QqDLtk5vm53PXzbFqSgsa4YgoecL1DtsQaE9p5A";
    hashOutput = false;
    sha256 = "05a81fbe0997f6274c7617efc351647be38e5244c2624bd203459025c9a68ecd";
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
    xproto
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

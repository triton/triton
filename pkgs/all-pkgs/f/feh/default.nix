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
  name = "feh-3.1.1";

  src = fetchurl {
    url = "https://feh.finalrewind.org/${name}.tar.bz2";
    multihash = "QmYiJet4kpVCdKeUin9NHzGC1Lz91Z2AYwY8SMDEzb8bF1";
    hashOutput = false;
    sha256 = "61d0242e3644cf7c5db74e644f0e8a8d9be49b7bd01034265cc1ebb2b3f9c8eb";
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

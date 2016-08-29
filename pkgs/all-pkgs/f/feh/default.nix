{ stdenv
, makeWrapper
, fetchurl

, curl
, imlib2
, libexif
, libjpeg
, libpng
, xorg
}:

stdenv.mkDerivation rec {
  name = "feh-2.17";

  src = fetchurl {
    url = "https://feh.finalrewind.org/${name}.tar.bz2";
    multihash = "QmdH43AW16i5v7Xs7JMiTLgPkV6yfuFT6cLMZPLSogz5AE";
    allowHashOutput = false;
    sha256 = "dfe6fd362a988eba964de3eb1ecc083cfbdf5132ade36e68b6f18e07a78980d4";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    curl
    imlib2
    libexif
    libpng
    xorg.libX11
    xorg.libXinerama
    xorg.libXt
    xorg.xproto
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

  meta = with stdenv.lib; {
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

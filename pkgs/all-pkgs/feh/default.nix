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
  name = "feh-2.16.1";

  src = fetchurl {
    url = "https://feh.finalrewind.org/${name}.tar.bz2";
    allowHashOutput = false;
    sha256 = "6e55289a3be4495a437a0b037c7b5e86edf64ec74ab63d2d26fa50df1b62b6b3";
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
    homepage = https://derf.homelinux.org/projects/feh/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

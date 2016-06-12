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
  name = "feh-2.16";

  src = fetchurl {
    url = "https://feh.finalrewind.org/${name}.tar.bz2";
    allowHashOutput = false;
    sha256 = "a2639dec600ffac3ac3d3ffb4254bef7385082b9c417bef72167b7b258778e4c";
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
    srcVerified = fetchurl {
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

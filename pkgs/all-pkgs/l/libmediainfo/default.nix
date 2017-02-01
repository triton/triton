{ stdenv
, autoreconfHook
, fetchurl

, curl
, libmms
, libzen
, zlib
}:

let
  version = "0.7.92";
in
stdenv.mkDerivation rec {
  name = "libmediainfo-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mediainfo/source/libmediainfo/${version}/"
      + "libmediainfo_${version}.tar.xz";
    sha256 = "63f8360b3abcb483ba1dd2ba7c8b2fb3c6b0dcf1383735375899a651f859320b";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    curl
    libmms
    libzen
    zlib
  ];

  sourceRoot = "./MediaInfoLib/Project/GNU/Library/";

  configureFlags = [
    "--enable-shared"
    "--with-libcurl"
    "--with-libmms"
  ];

  postInstall = ''
    install -D -m 644 -v 'libmediainfo.pc' "$out/lib/pkgconfig/libmediainfo.pc"
  '';

  meta = with stdenv.lib; {
    description = "Shared library for mediainfo";
    homepage = http://mediaarea.net/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

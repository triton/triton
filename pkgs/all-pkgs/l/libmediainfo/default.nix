{ stdenv
, autoreconfHook
, fetchurl
, lib

, curl
, libmms
, libzen
, zlib
}:

let
  version = "0.7.93";
in
stdenv.mkDerivation rec {
  name = "libmediainfo-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mediainfo/source/libmediainfo/${version}/"
      + "libmediainfo_${version}.tar.xz";
    sha256 = "3624a187c7159a055805a475e4bbcfd3d55b77b765507fd066b205cd55902114";
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

  meta = with lib; {
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

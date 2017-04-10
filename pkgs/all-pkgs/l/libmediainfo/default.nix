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
  version = "0.7.94";
in
stdenv.mkDerivation rec {
  name = "libmediainfo-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mediainfo/source/libmediainfo/${version}/"
      + "libmediainfo_${version}.tar.xz";
    sha256 = "10e7926373611815e494ff00ee0fc8766076b4f241da153a9baf7dfa029cad32";
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

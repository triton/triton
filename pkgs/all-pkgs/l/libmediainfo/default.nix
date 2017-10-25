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
  version = "0.7.95";
in
stdenv.mkDerivation rec {
  name = "libmediainfo-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mediainfo/source/libmediainfo/${version}/"
      + "libmediainfo_${version}.tar.xz";
    sha256 = "432cd106d93fa067d61b36bad5376a431448fea1fa40b7397b851506b562d96a";
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

  srcRoot = "./MediaInfoLib/Project/GNU/Library/";

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

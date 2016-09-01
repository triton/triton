{ stdenv
, autoreconfHook
, fetchurl

, curl
, libmms
, libzen
, zlib
}:

let
  version = "0.7.88";
in
stdenv.mkDerivation rec {
  name = "libmediainfo-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mediainfo/libmediainfo_${version}.tar.xz";
    multihash = "QmXzWzZWutwmezQKxBqqenNyRAaHnymgzgvpPbehXr4KLQ";
    sha256 = "01de70bc67f2da4b6d2cde5aac0bf38b2e9ab834279b90c89cc3a3d1d47b14ec";
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

{ stdenv
, fetchurl
, perl

, bzip2
, zlib
}:

stdenv.mkDerivation rec {
  name = "libzip-1.3.2";

  src = fetchurl {
    url = "https://www.nih.at/libzip/${name}.tar.xz";
    multihash = "Qmf1txkDK5y8ARKb9LDi2jxYLcvsLh3zJVEwpSSYWFjhzs";
    sha256 = "6277845010dbc20e281a77e637c97765c1323d67df4d456fd942f525ea86e185";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    bzip2
    zlib
  ];

  preInstall = ''
    patchShebangs man/handle_links
  '';

  meta = with stdenv.lib; {
    homepage = https://www.nih.at/libzip;
    description = "A C library for reading, creating and modifying zip archives";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

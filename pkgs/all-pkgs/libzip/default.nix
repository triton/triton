{ stdenv
, fetchurl
, perl

, zlib
}:

stdenv.mkDerivation rec {
  name = "libzip-1.1.3";

  src = fetchurl {
    url = "https://nih.at/libzip/${name}.tar.xz";
    sha256 = "729a295a59a9fd6e5b9fe9fd291d36ae391a9d2be0b0824510a214cfaa05ceee";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    zlib
  ];

  preInstall = ''
    patchShebangs man/handle_links
  '';

  meta = with stdenv.lib; {
    homepage = http://www.nih.at/libzip;
    description = "A C library for reading, creating and modifying zip archives";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

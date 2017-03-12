{ stdenv
, fetchurl
, perl

, zlib
}:

stdenv.mkDerivation rec {
  name = "libzip-1.2.0";

  src = fetchurl {
    url = "https://www.nih.at/libzip/${name}.tar.xz";
    multihash = "QmRCdruhq1ijRiNFvquzq9QE8f786e9C6ueZtHovRV7atu";
    sha256 = "ffc0764395fba3d45dc5a6e32282788854618b9e9838337f8218b596007f1376";
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
    homepage = https://www.nih.at/libzip;
    description = "A C library for reading, creating and modifying zip archives";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

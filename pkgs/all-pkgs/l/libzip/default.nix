{ stdenv
, fetchurl
, perl

, bzip2
, zlib
}:

stdenv.mkDerivation rec {
  name = "libzip-1.3.0";

  src = fetchurl {
    url = "https://www.nih.at/libzip/${name}.tar.xz";
    multihash = "QmfBKAT8MbgGGB5QzYFN7XjtFn8F1oVLYE4WCXtBCd8of6";
    sha256 = "aa936efe34911be7acac2ab07fb5c8efa53ed9bb4d44ad1fe8bff19630e0d373";
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

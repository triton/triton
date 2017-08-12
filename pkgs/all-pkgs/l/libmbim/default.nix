{ stdenv
, fetchurl
, python

, glib
, libgudev
}:

stdenv.mkDerivation rec {
  name = "libmbim-1.14.2";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libmbim/${name}.tar.xz";
    multihash = "QmaCdwLjoRqvJxArMcu28kkDcNDqH5zHKVHWvjFbknVNaD";
    sha256 = "22cafe6b8432433aa58bedcf7db71111522ce6531bfe24e8e9b6058412cd31cf";
  };

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    glib
    libgudev
  ];

  postPatch = ''
    patchShebangs .
  '';

  meta = with stdenv.lib; {
    homepage = http://www.freedesktop.org/software/libmbim/;
    description = "Library for WWAN modems & devices which use the Mobile Broadband Interface Model (MBIM) protocol";
    license = with licenses; [
      gpl2Plus
      lgpl21Plus
    ];
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

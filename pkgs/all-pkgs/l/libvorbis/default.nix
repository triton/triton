{ stdenv
, fetchurl
, lib

, libogg
}:

stdenv.mkDerivation rec {
  name = "libvorbis-1.3.6";

  src = fetchurl {
    url = "mirror://xiph/vorbis/${name}.tar.xz";
    multihash = "QmPUzaqHq8YqpY3goemoexYRPQ5hyJLfJjSjdCbyWX2x65";
    sha256 = "af00bb5a784e7c9e69f56823de4637c350643deedaf333d0fa86ecdba6fcb415";
  };

  buildInputs = [
    libogg
  ];

  meta = with lib; {
    homepage = http://xiph.org/vorbis/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

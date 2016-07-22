{ stdenv
, fetchurl
, gettext

, expat
, zlib
}:

stdenv.mkDerivation rec {
  name = "exiv2-0.25";

  src = fetchurl {
    url = "http://www.exiv2.org/${name}.tar.gz";
    multihash = "QmbXb7zCNYLyrAHjVnA2NUGcary3orL7sV7KR8moMPiZBp";
    sha256 = "197g6vgcpyf9p2cwn5p5hb1r714xsk1v4p96f5pv1z8mi9vzq2y8";
  };

  postPatch = ''
    patchShebangs ./src/svn_version.sh
  '';

  nativeBuildInputs = [
    gettext
  ];

  propagatedBuildInputs = [
    expat
    zlib
  ];

  meta = with stdenv.lib; {
    homepage = http://www.exiv2.org/;
    description = "A library and command-line utility to manage image metadata";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

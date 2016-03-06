{ stdenv
, fetchurl

, libogg
, libvorbis
}:

stdenv.mkDerivation rec {
  name = "libtheora-1.1.1";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/theora/${name}.tar.gz";
    sha256 = "0swiaj8987n995rc7hw0asvpwhhzpjiws8kr3s6r44bqqib2k5a0";
  };

  buildInputs = [
    libogg
    libvorbis
  ];

  meta = with stdenv.lib; {
    homepage = http://www.theora.org/;
    description = "Library for Theora, a free and open video compression format";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

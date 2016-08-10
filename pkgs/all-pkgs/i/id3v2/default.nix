{ stdenv
, fetchurl
, groff

, id3lib
, zlib
}:

stdenv.mkDerivation rec {
  name = "id3v2-${version}";
  version = "0.1.12";

  src = fetchurl {
    url = "mirror://sourceforge/id3v2/${name}.tar.gz";
    sha256 = "8105fad3189dbb0e4cb381862b4fa18744233c3bbe6def6f81ff64f5101722bf";
  };

  nativeBuildInputs = [
    groff
  ];

  buildInputs = [
    id3lib
    zlib
  ];

  makeFlags = [
    "PREFIX=$(out)"
  ];

  preInstall = ''
    mkdir -pv $out/{bin,share/man/man1}
  '';

  meta = with stdenv.lib; {
    description = "A command line editor for id3v2 tags";
    homepage = http://id3v2.sourceforge.net/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

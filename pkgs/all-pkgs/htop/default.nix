{ stdenv
, fetchurl

, ncurses
}:

stdenv.mkDerivation rec {
  name = "htop-${version}";
  version = "2.0.1";

  src = fetchurl {
    url = "http://hisham.hm/htop/releases/${version}/${name}.tar.gz";
    sha256 = "0rjn9ybqx5sav7z4gn18f1q6k23nmqyb6yydfgghzdznz9nn447l";
  };

  buildInputs = [
    ncurses
  ];

  meta = with stdenv.lib; {
    description = "An interactive process viewer for Linux";
    homepage = "http://htop.sourceforge.net";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

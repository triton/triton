{ stdenv
, fetchurl
, lib

, ncurses
}:

let
  version = "1.4rc5";
in
stdenv.mkDerivation rec {
  name = "aalib-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/aa-project/aa-lib/${version}/${name}.tar.gz";
    sha256 = "1vkh19gb76agvh4h87ysbrgy82hrw88lnsvhynjf4vng629dmpgv";
  };

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--without-x"
    "--with-ncurses=${ncurses}"
  ];

  meta = with lib; {
    description = "ASCII art graphics library";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
, lib

, ncurses
, pcre
, readline
}:

stdenv.mkDerivation rec {
  name = "atftp-0.7.1";

  src = fetchurl {
    url = "mirror://sourceforge/atftp/${name}.tar.gz";
    sha256 = "ae4c6f09cadb8d2150c3ce32d88f19036a54e8211f22d723e97864bb5e18f92d";
  };

  buildInputs = [
    ncurses
    pcre
    readline
  ];

  # Expects old c but doesn't specify this
  NIX_CFLAGS_COMPILE = "-std=gnu89";

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

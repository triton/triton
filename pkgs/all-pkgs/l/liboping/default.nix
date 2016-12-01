{ stdenv
, fetchurl
, perl

, ncurses
}:

stdenv.mkDerivation rec {
  name = "liboping-1.9.0";

  src = fetchurl {
    url = "https://noping.cc/files/${name}.tar.bz2";
    multihash = "QmURdTgYNx6yPDdtSDstVjdy5W26isJQwUm9BYVErASQAd";
    sha256 = "44bb1d88b56b88fda5533edb3aa005c69b3cd396f20453a157d7e31e536f3530";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    ncurses
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

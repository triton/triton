{ stdenv
, fetchurl

, libnl
, ncurses
, pciutils
}:

stdenv.mkDerivation rec {
  name = "powertop-2.8";

  src = fetchurl {
    url = "https://01.org/sites/default/files/downloads/powertop/${name}.tar.gz";
    sha256 = "a87b563f73106babfa3e74dcf92f252938c061e309ace20a361358bbfa579c5a";
  };

  buildInputs = [
    libnl
    ncurses
    pciutils
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

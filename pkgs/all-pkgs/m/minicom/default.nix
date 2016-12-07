{ stdenv
, fetchurl

, ncurses
}:

stdenv.mkDerivation {
  name = "minicom-2.7";

  src = fetchurl {
    url = "https://alioth.debian.org/frs/download.php/file/3977/minicom-2.7.tar.gz";
    multihash = "QmVc4tikrQXUJZD9TCBzvRus6dCYa8DfkrsbemJCsjyiLa";
    sha256 = "9ac3a663b82f4f5df64114b4792b9926b536c85f59de0f2d2b321c7626a904f4";
  };

  buildInputs = [
    ncurses
  ];

  postPatch = ''
    sed -i 's/test -d \$UUCPLOCK/true/g' configure
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-lock-dir=/var/lock"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

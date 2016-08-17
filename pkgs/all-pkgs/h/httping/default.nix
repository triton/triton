{ stdenv
, fetchurl
, gettext

, fftw_double
, ncurses
, openssl
}:

stdenv.mkDerivation rec {
  name = "httping-2.4";

  src = fetchurl {
    url = "https://www.vanheusden.com/httping/${name}.tgz";
    multihash = "QmbiJH478zL3yz3DzGr6HVjRS4N5tA6aeXnrnf5PWpwT1M";
    sha256 = "dab59f02b08bfbbc978c005bb16d2db6fe21e1fc841fde96af3d497ddfc82084";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    fftw_double
    ncurses
    openssl
  ];

  dontAddPrefix = true;

  configureFlags = [
    "--with-tfo"
    "--with-ncurses"
    "--with-openssl"
    "--with-fftw3"
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

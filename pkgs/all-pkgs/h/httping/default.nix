{ stdenv
, fetchurl
, gettext

, fftw_double
, ncurses
, openssl
}:

stdenv.mkDerivation rec {
  name = "httping-2.5";

  src = fetchurl {
    url = "https://www.vanheusden.com/httping/${name}.tgz";
    multihash = "QmSd6Cengd6iqWepaFn1yb5ZggvJUutvjdG6xgLwVgiu6v";
    sha256 = "3e895a0a6d7bd79de25a255a1376d4da88eb09c34efdd0476ab5a907e75bfaf8";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    fftw_double
    ncurses
    openssl
  ];

  addPrefix = false;

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

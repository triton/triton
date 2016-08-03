{ stdenv
, autoconf
, fetchurl

, ncurses
}:

stdenv.mkDerivation rec {
  name="mtr-0.87";
  
  src = fetchurl {
    url = "ftp://ftp.bitwizard.nl/mtr/${name}.tar.gz";
    multihash = "Qmf153tZNQG7vjup3i3cVK4EvxC1eQ4xkYJ4HYskNkcfTg";
    sha256 = "17zi99n8bdqrwrnbfyjn327jz4gxx287wrq3vk459c933p34ff8r";
  };

  nativeBuildInputs = [
    autoconf
  ];

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--without-gtk"
  ];

  meta = with stdenv.lib; {
    homepage = http://www.bitwizard.nl/mtr/;
    description = "A network diagnostics tool";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}


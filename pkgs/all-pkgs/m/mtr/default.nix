{ stdenv
, autoconf
, fetchurl

, libcap
, ncurses
}:

stdenv.mkDerivation rec {
  name="mtr-0.92";
  
  src = fetchurl {
    url = "ftp://ftp.bitwizard.nl/mtr/${name}.tar.gz";
    multihash = "QmedTmUYx5N4NtHMAuNA7aSVPVmHLHwKJw9rDGPiZTAuu3";
    sha256 = "f2979db9e2f41aa8e6574e7771767c9afe111d9213814eb47f5e1e71876e4382";
  };

  nativeBuildInputs = [
    autoconf
  ];

  buildInputs = [
    libcap
    ncurses
  ];

  postPatch = ''
    sed -i '/install-exec-hook/d' Makefile.in
  '';

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


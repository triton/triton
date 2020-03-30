{ stdenv
, autoconf
, fetchurl

, libcap
, ncurses
}:

stdenv.mkDerivation rec {
  name = "mtr-0.93";
  
  src = fetchurl {
    url = "ftp://ftp.bitwizard.nl/mtr/${name}.tar.gz";
    multihash = "QmS3LAUhuR55k1zRQ2s6Qumkrva4nuV2rhnSd4FwfgCEEs";
    sha256 = "229c673d637bd7dbb96471623785a47e85da0b1944978200c949994c1e6af10d";
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


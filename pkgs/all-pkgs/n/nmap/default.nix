{ stdenv
, fetchurl

, libpcap
, openssl
, pcre
, python2Packages
}:

stdenv.mkDerivation rec {
  name = "nmap-7.12";

  src = fetchurl {
    url = "https://nmap.org/dist/${name}.tar.bz2";
    sha256 = "63df082a87c95a189865d37304357405160fc6333addcf5b84204c95e0539b04";
  };

  nativeBuildInputs = [
    python2Packages.wrapPython
  ];

  buildInputs = [
    libpcap
    openssl
    pcre
    python2Packages.python
  ];

  configureFlags = [
    "--without-zenmap"
    "--without-nmap-update"
  ];

  preFixup = ''
    wrapPythonPrograms $out/bin
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

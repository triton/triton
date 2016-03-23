{ stdenv
, fetchurl

, libpcap
, openssl
, pcre
, python2Packages
}:

stdenv.mkDerivation rec {
  name = "nmap-7.11";

  src = fetchurl {
    url = "https://nmap.org/dist/${name}.tar.bz2";
    sha256 = "13fa971555dec00e495a5b72c1f9efa1363b8e6c7388a2f05117cb0778c0954a";
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

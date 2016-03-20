{ stdenv
, fetchurl

, libpcap
, openssl
, pcre
, python2Packages
}:

stdenv.mkDerivation rec {
  name = "nmap-7.10";

  src = fetchurl {
    url = "https://nmap.org/dist/${name}.tar.bz2";
    sha256 = "58cf8896d09057d1c3533f430c06b22791d0227ebbb93dede2ccb73693ed4b4b";
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

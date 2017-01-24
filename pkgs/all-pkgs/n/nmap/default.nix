{ stdenv
, fetchurl

, libpcap
, openssl
, pcre
, python2Packages
}:

let
  baseUrls = [
    "https://nmap.org/dist"
  ];
in
stdenv.mkDerivation rec {
  name = "nmap-7.40";

  src = fetchurl {
    urls = map (n: "${n}/${name}.tar.bz2") baseUrls;
    multihash = "QmUDaE8ELC6CdsgXdo8vX4VqqXN7dTy3WvR65W2q4Cd9Zg";
    hashOutput = false;
    sha256 = "9e14665fffd054554d129d62c13ad95a7b5c7a046daa2290501909e65f4d3188";
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}/sigs/${name}.tar.bz2.asc") baseUrls;
      pgpKeyFingerprint = "436D 66AB 9A79 8425 FDA0  E3F8 01AF 9F03 6B93 55D0";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

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
  name = "nmap-7.31";

  src = fetchurl {
    url = map (n: "${n}/${name}.tar.bz2") baseUrls;
    hashOutput = false;
    multihash = "QmZxtyZVPQWkRYhAv5DpifH1JmVzsMGwhDga8xx4GKZcoQ";
    sha256 = "cb9f4e03c0771c709cd47dc8fc6ac3421eadbdd313f0aae52276829290583842";
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

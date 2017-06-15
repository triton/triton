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
  name = "nmap-7.50";

  src = fetchurl {
    urls = map (n: "${n}/${name}.tar.bz2") baseUrls;
    multihash = "Qmbq72FwwZv2vNZwL8wvMgzqVWo6EVDWzAjGuvUhtoSzWW";
    hashOutput = false;
    sha256 = "e9a96a8e02bfc9e80c617932acc61112c23089521ee7d6b1502ecf8e3b1674b2";
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

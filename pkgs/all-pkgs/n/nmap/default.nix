{ stdenv
, fetchurl

, libpcap
, openssl
, pcre
, python2Packages
, zlib
}:

let
  baseUrls = [
    "https://nmap.org/dist"
  ];
in
stdenv.mkDerivation rec {
  name = "nmap-7.60";

  src = fetchurl {
    urls = map (n: "${n}/${name}.tar.bz2") baseUrls;
    multihash = "QmSd9BAjL53EXssomcQAJp7GD9vyWDPmMe5MEzqisKAMRC";
    hashOutput = false;
    sha256 = "a8796ecc4fa6c38aad6139d9515dc8113023a82e9d787e5a5fb5fa1b05516f21";
  };

  nativeBuildInputs = [
    python2Packages.wrapPython
  ];

  buildInputs = [
    libpcap
    openssl
    pcre
    python2Packages.python
    zlib
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

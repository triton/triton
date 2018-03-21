{ stdenv
, fetchurl

, liblinear
, libpcap
, libssh2
, lua
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
  name = "nmap-7.70";

  src = fetchurl {
    urls = map (n: "${n}/${name}.tar.bz2") baseUrls;
    multihash = "QmdByChZAjZradH73dAockfRumaEpgA3X7DqAeLA4kabMb";
    hashOutput = false;
    sha256 = "847b068955f792f4cc247593aca6dc3dc4aae12976169873247488de147a6e18";
  };

  nativeBuildInputs = [
    python2Packages.wrapPython
  ];

  buildInputs = [
    liblinear
    libpcap
    libssh2
    lua
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

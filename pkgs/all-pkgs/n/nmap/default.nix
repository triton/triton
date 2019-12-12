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
  name = "nmap-7.80";

  src = fetchurl {
    urls = map (n: "${n}/${name}.tar.bz2") baseUrls;
    multihash = "QmaLKzYUGcwGLyUVvEmwLPss7HtF97H3AZP37Zjn2TmK2f";
    hashOutput = false;
    sha256 = "fcfa5a0e42099e12e4bf7a68ebe6fde05553383a682e816a7ec9256ab4773faa";
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

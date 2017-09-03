{ stdenv
, fetchurl

, zlib
}:

stdenv.mkDerivation rec {
  name = "file-5.32";

  src = fetchurl {
    url = "ftp://ftp.astron.com/pub/file/${name}.tar.gz";
    multihash = "QmchzYpNV6HRqGer6eZkoEZdMTu3X7QZi6NeKBJ2QmWCtW";
    hashOutput = false;
    sha256 = "8639dc4d1b21e232285cd483604afc4a6ee810710e00e579dbe9591681722b50";
  };

  buildInputs = [
    zlib
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "BE04 995B A8F9 0ED0 C0C1  76C4 7111 2AB1 6CB3 3B3A";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A program that shows the type of files";
    homepage = "http://darwinsys.com/file";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

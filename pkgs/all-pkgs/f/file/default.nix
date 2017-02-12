{ stdenv
, fetchurl

, zlib
}:

stdenv.mkDerivation rec {
  name = "file-5.30";

  src = fetchurl {
    url = "ftp://ftp.astron.com/pub/file/${name}.tar.gz";
    multihash = "QmSwGNx83XDeeQiegU9eCPXQ9CoPPBVEPS4dfqiM2MYpJp";
    hashOutput = false;
    sha256 = "694c2432e5240187524c9e7cf1ec6acc77b47a0e19554d34c14773e43dbbf214";
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

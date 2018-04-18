{ stdenv
, fetchurl

, libseccomp
, zlib
}:

stdenv.mkDerivation rec {
  name = "file-5.33";

  src = fetchurl {
    url = "ftp://ftp.astron.com/pub/file/${name}.tar.gz";
    multihash = "QmcLhzLgJJ8M6krx9JKHKyNPXK6nx176GkE7pVYfvc3HSs";
    hashOutput = false;
    sha256 = "1c52c8c3d271cd898d5511c36a68059cda94036111ab293f01f83c3525b737c6";
  };

  buildInputs = [
    libseccomp
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

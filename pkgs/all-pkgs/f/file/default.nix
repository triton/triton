{ stdenv
, fetchurl

, libseccomp
, zlib
}:

stdenv.mkDerivation rec {
  name = "file-5.35";

  src = fetchurl {
    url = "ftp://ftp.astron.com/pub/file/${name}.tar.gz";
    multihash = "QmbMKFj8GB1VC3rfTVE1jyZHogXAbfbtdWAo3hapAPdJeK";
    hashOutput = false;
    sha256 = "30c45e817440779be7aac523a905b123cba2a6ed0bf4f5439e1e99ba940b5546";
  };

  buildInputs = [
    libseccomp
    zlib
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "BE04 995B A8F9 0ED0 C0C1  76C4 7111 2AB1 6CB3 3B3A";
      };
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

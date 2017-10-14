{ stdenv
, fetchurl
, iasl
, python

, zlib
}:

stdenv.mkDerivation rec {
  name = "qemu-2.10.1";

  src = fetchurl {
    url = "http://wiki.qemu-project.org/download/${name}.tar.bz2";
    multihash = "QmNjp2xNu4xU6jJZ9DpknWENsbzZPrxWHHVG3HZcKxi5Y9";
    hashOutput = false;
    sha256 = "8e040bc7556401ebb3a347a8f7878e9d4028cf71b2744b1a1699f4e741966ba8";
  };

  nativeBuildInputs = [
    iasl
    python
  ];

  buildInputs = [
    zlib
  ];

  configureFlags = [
    "--help"
    "--enable-modules"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "CEAC C9E1 5534 EBAB B82D  3FA0 3353 C9CE F108 B584";
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

{ stdenv
, fetchurl
, iasl
, python

, zlib
}:

stdenv.mkDerivation rec {
  name = "qemu-2.8.0";

  src = fetchurl {
    url = "http://wiki.qemu-project.org/download/${name}.tar.bz2";
    multihash = "QmRvELhGfxezAs6tKsGoG8xe38rY8FMDqsqNxHdAQLb8dX";
    hashOutput = false;
    sha256 = "dafd5d7f649907b6b617b822692f4c82e60cf29bc0fc58bc2036219b591e5e62";
  };

  nativeBuildInputs = [
    iasl
    python
  ];

  buildInputs = [
    zlib
  ];

  configureFlags = [
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

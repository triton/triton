{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "gdb-7.12";

  src = fetchurl {
    url = "mirror://gnu/gdb/${name}.tar.xz";
    hashOutput = false;
    sha256 = "834ff3c5948b30718343ea57b11cbc3235d7995c6a4f3a5cecec8c8114164f94";
  };

  configureFlags = [
    "--help"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "F40A DB90 2B24 264A A42E  50BF 92ED B04B FF32 5CF3";
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

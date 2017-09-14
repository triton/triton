{ stdenv
, fetchurl

, libcdio
}:

stdenv.mkDerivation rec {
  name = "libburn-1.4.8";

  src = fetchurl {
    url = "http://files.libburnia-project.org/releases/${name}.tar.gz";
    multihash = "QmaPEPX5ZQ4eJwzVVKDLm9gVP5aZBDyEURuXE8mj55eYYA";
    hashOutput = false;
    sha256 = "3e81a2e359376c38d96239a9c9967be715f706d150d89c337de0fc85ecb79da6";
  };

  buildInputs = [
    libcdio
  ];

  configureFlags = [
    "--enable-libcdio"
    "--enable-pkg-check-modules"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "44BC 9FD0 D688 EB00 7C4D  D029 E9CB DFC0 ABC0 A854";
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

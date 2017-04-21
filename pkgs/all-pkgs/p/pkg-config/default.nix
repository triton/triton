{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "pkg-config-0.29.2";
  
  src = fetchurl {
    url = "https://pkg-config.freedesktop.org/releases/${name}.tar.gz";
    multihash = "QmacZ7gz8BvjfxsSmQ7Fu5TvqdWTJQfA8XGuTrrCLvWZV2";
    hashOutput = false;
    sha256 = "6fc69c01688c9458a57eb9a1664c9aba372ccda420a02bf4429fe610e7e7d591";
  };

  configureFlags = [
    "--with-internal-glib"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "6B99 CE97 F17F 48C2 7F72  2D71 023A 4420 C7EC 6914";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A tool that allows packages to find out information about other packages";
    homepage = http://pkg-config.freedesktop.org/wiki/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
, python

, gtk2
, libsndfile
}:

stdenv.mkDerivation rec {
  name = "lv2-1.12.0";

  src = fetchurl {
    url = "http://lv2plug.in/spec/${name}.tar.bz2";
    sha256 = "7a4a53138f10ed997174c8bc5a8573d5f5a5d8441aaac2de6cf2178ff90658e9";
  };

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    gtk2
    libsndfile
  ];

  postPatch = ''
    patchShebangs ./waf
  '';

  configurePhase = ''
    ./waf configure --prefix=$out
  '';

  buildPhase = ''
    ./waf
  '';

  installPhase = ''
    ./waf install
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "907D 226E 7E13 FA33 7F01  4A08 3672 782A 9BF3 68F3";
    };
  };

  meta = with stdenv.lib; {
    description = "A plugin standard for audio systems";
    homepage = http://lv2plug.in;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

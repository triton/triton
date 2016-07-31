{ stdenv
, fetchurl
, python

, lv2
, serd
, sord
, sratom
}:

stdenv.mkDerivation rec {
  name = "lilv-${version}";
  version = "0.22.0";

  src = fetchurl {
    url = "https://download.drobilla.net/${name}.tar.bz2";
    sha256 = "cd279321223ef11ca01551767d3c16d68cb31f689e02320a0b2e37b4f7d17ab4";
  };

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    lv2
    serd
    sord
    sratom
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
    description = "A C library to make the use of LV2 plugins";
    homepage = https://drobilla.net/software/lilv;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

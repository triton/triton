{ stdenv
, fetchurl
, python

, serd
}:

stdenv.mkDerivation rec {
  name = "sord-0.14.0";

  src = fetchurl {
    url = "https://download.drobilla.net/${name}.tar.bz2";
    sha256 = "7656d8ec56a43e0f0a168fe78670a7628a42d3a597b53c7a72ac243a74e0f19a";
  };

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    serd
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
    description = "A lightweight C library for storing RDF data in memory";
    homepage = https://drobilla.net/software/sord;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
, python

, pcre
}:

stdenv.mkDerivation rec {
  name = "serd-0.22.0";

  src = fetchurl {
    url = "https://download.drobilla.net/${name}.tar.bz2";
    sha256 = "7b030287b4b75f35e6212b145648bec0be6580cc5434caa6d2fe64a38562afd2";
  };

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    pcre
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
    homepage = http://drobilla.net/software/serd;
    description = "A library for reading and writing RDF syntax Turtle and NTriples";
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

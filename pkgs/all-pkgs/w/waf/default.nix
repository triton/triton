{ stdenv
, fetchurl

, python2
}:

stdenv.mkDerivation rec {
  name = "waf-1.9.3";

  src = fetchurl {
    url = "https://waf.io/${name}.tar.bz2";
    multihash = "QmerWxk5w69MvZLaEdMrW827cP2tZKDi9zSzqQG2bBAdXY";
    #hashOutput = false;
    sha256 = "1799bf4a4782552f673084a9a08ea29b4f16cb06b24b1f643dd7799332c6eac7";
  };

  buildInputs = [
    python2
  ];

  setupHook = ./setup-hook.sh;

  postPatch = ''
    patchShebangs ./waf-light
  '';

  configurePhase = ''
    ./waf-light configure
  '';

  buildPhase = ''
    ./waf-light build
  '';

  installPhase = ''
    install -D -m755 -v waf $out/bin/waf
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "";
    };
  };

  meta = with stdenv.lib; {
    description = "Meta build system";
    homepage = https://waf.io/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

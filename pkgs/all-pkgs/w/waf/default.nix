{ stdenv
, fetchurl

, python2
}:

stdenv.mkDerivation rec {
  name = "waf-1.9.2";

  src = fetchurl {
    url = "https://waf.io/${name}.tar.bz2";
    sha256 = "2eb02767b611c291bf5ce581624b360d354d5fa929fadfb275fcd223c5f8bfb6";
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

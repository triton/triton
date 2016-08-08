{ stdenv
, fetchurl

, python2
}:

stdenv.mkDerivation rec {
  name = "waf-${version}";
  version = "1.9.2";

  src = fetchurl {
    url = "https://waf.io/waf-${version}.tar.bz2";
    sha256 = "2eb02767b611c291bf5ce581624b360d354d5fa929fadfb275fcd223c5f8bfb6";
  };

  buildInputs = [
    python2
  ];

  configurePhase = ''
    python waf-light configure
  '';

  buildPhase = ''
    python waf-light build
  '';

  installPhase = ''
    install waf $out
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

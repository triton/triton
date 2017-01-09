{ stdenv
, bison
, fetchurl
, m4
}:

let
  version = "2.6.3";
in
stdenv.mkDerivation rec {
  name = "flex-${version}";

  src = fetchurl {
    url = "https://github.com/westes/flex/releases/download/v${version}/${name}.tar.gz";
    sha256 = "68b2742233e747c462f781462a2a1e299dc6207401dac8f0bbb316f48565c2aa";
  };

  nativeBuildInputs = [
    bison
    m4
  ];

  # Using static libraries fixes issues with references to
  # yylex in flex 2.6.0
  # This can be tested by building glusterfs
  configureFlags = [
    "--disable-shared"
  ];

  dontDisableStatic = true;

  meta = with stdenv.lib; {
    description = "A fast lexical analyser generator";
    homepage = http://flex.sourceforge.net/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

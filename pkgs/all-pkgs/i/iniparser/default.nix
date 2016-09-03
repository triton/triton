{ stdenv
, fetchFromGitHub
, fetchTritonPatch
}:

stdenv.mkDerivation rec {
  name = "iniparser-${version}";
  version = "4.0";

  src = fetchFromGitHub {
    version = 1;
    owner = "ndevilla";
    repo = "iniparser";
    rev = "v${version}";
    sha256 = "619194948447cf0e2bb76fbfad1561a86a0cf089700116f3ce08216d2f0fb27d";
  };

  patches = [
    (fetchTritonPatch {
      rev = "7b328573fd49ff0b2ab3a56e51f37ffcb4275fec";
      file = "iniparser/iniparser-4.0-no-usr.patch";
      sha256 = "bc46f43470ede9d504755491a01d3000f3dcdf3e9b2d7d950dcd32be2fdc5e79";
    })
  ];

  buildFlags = [
    "CC=cc"
    "libiniparser.so"
  ];

  installPhase = ''
    install -D -m644 -v 'src/dictionary.h' "$out/include/dictionary.h"
    install -D -m644 -v 'src/iniparser.h' "$out/include/iniparser.h"

    install -D -m644 -v 'libiniparser.so.0' "$out/lib/libiniparser.so.0"
    ln -sv $out/lib/libiniparser.so.0 $out/lib/libiniparser.so

    mkdir -pv "$out/share/doc/${name}"
    cp -rv html $out/share/doc/${name}
  '';

  meta = with stdenv.lib; {
    description = "Free standalone ini file parsing library";
    homepage = http://ndevilla.free.fr/iniparser;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}

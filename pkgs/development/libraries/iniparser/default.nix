{ stdenv, fetchFromGitHub }:

let
  inherit (stdenv.lib) optional;
in
stdenv.mkDerivation rec {
  name = "iniparser-${version}";
  version = "4.0";

  src = fetchFromGitHub {
    owner = "ndevilla";
    repo = "iniparser";
    rev = "v${version}";
    sha256 = "619194948447cf0e2bb76fbfad1561a86a0cf089700116f3ce08216d2f0fb27d";
  };

  patches = ./no-usr.patch;

  buildFlags = [ "libiniparser.so" "CC=cc" ];

  installPhase = ''
    mkdir -p $out/lib

    mkdir -p $out/include
    cp src/*.h $out/include

    mkdir -p $out/share/doc/${name}
    cp -r html $out/share/doc/${name}

  '' + ''
    cp libiniparser.so.0 $out/lib
    ln -s libiniparser.so.0 $out/lib/libiniparser.so
  '';

  meta = {
    homepage = http://ndevilla.free.fr/iniparser;
    description = "Free standalone ini file parsing library";
    license = stdenv.lib.licenses.mit;
  };
}

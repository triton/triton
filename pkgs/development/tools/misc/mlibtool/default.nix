{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "mlibtool-2014-06-01";

  src = fetchFromGitHub {
    owner = "GregorR";
    repo = "mlibtool";
    rev = "9ac89ba57cb20c132df7ac2fee9b929d26fda98f";
    sha256 = "1hjkiqicsngywsv1dwqnply77wbks1gma070z3fapal6nslnrkv3";
  };

  installPhase = ''
    mkdir -p $out/bin $out/share/aclocal
    cp {ac,}mlibtool $out/bin
    cp *.m4 $out/share/aclocal
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    platforms = platforms.all;
  };
}

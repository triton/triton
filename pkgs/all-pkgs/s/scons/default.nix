{ stdenv
, buildPythonPackage
, fetchurl
, lib
}:

let
  version = "3.0.1";
in
buildPythonPackage rec {
  name = "scons-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/scons/scons/${version}/${name}.tar.gz";
    sha256 = "24475e38d39c19683bc88054524df018fe6949d70fbd4c69e298d39a0269f173";
  };

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    homepage = "http://scons.org/";
    description = "An improved, cross-platform substitute for Make";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

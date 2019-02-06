{ stdenv
, buildPythonPackage
, fetchurl
, lib
}:

let
  version = "3.0.4";
in
buildPythonPackage rec {
  name = "scons-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/scons/scons/${version}/${name}.tar.gz";
    sha256 = "e2b8b36e25492720a05c0f0a92a219b42d11ce0c51e3397a1e8296dfea1d9b1a";
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

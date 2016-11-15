{ stdenv
, fetchurl
, pythonPackages
}:

let
  version = "2.5.1";
in
pythonPackages.buildPythonPackage rec {
  name = "scons-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/scons/scons/${version}/${name}.tar.gz";
    sha256 = "0b25218ae7b46a967db42f2a53721645b3d42874a65f9552ad16ce26d30f51f2";
  };

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
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

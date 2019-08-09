{ stdenv
, buildPythonPackage
, fetchurl
, lib
}:

let
  version = "3.1.1";
in
buildPythonPackage rec {
  name = "scons-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/scons/scons/${version}/${name}.tar.gz";
    sha256 = "4cea417fdd7499a36f407923d03b4b7000b0f9e8fd7b31b316b9ce7eba9143a5";
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

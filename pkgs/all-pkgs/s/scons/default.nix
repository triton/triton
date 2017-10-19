{ stdenv
, buildPythonPackage
, fetchurl
}:

let
  version = "3.0.0";
in
buildPythonPackage rec {
  name = "scons-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/scons/scons/${version}/${name}.tar.gz";
    sha256 = "0f532f405b98c60b731d231b3c503ab5bf47d89a6f66f70cb62c9249e9f45216";
  };

  # Fix for python2 compatability
  postPatch = ''
    grep -q 'from __future__ import print_function' \
      engine/SCons/Script/SConscript.py
    sed -i '/from __future__ import print_function/d' \
      engine/SCons/Script/SConscript.py
  '';

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

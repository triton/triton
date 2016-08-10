{ stdenv
, buildPythonPackage
, fetchPyPi

, netaddr
, pydenticon
, pysaml2
}:

let
  version = "0.7.18";
in
buildPythonPackage {
  name = "netaddr-${version}";

  src = fetchPyPi {
    package = "netaddr";
    inherit version;
    sha256 = "06dxjlbcicq7q3vqy8agq11ra01kvvd47j4mk6dmghjsyzyckxd1";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

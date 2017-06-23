{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, netaddr
, pydenticon
, pysaml2
}:

let
  version = "0.7.19";
in
buildPythonPackage {
  name = "netaddr-${version}";

  src = fetchPyPi {
    package = "netaddr";
    inherit version;
    sha256 = "38aeec7cdd035081d3a4c306394b19d677623bf76fa0913f6695127c7753aefd";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

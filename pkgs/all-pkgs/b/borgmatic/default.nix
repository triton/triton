{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pykwalify
, ruamel-yaml
}:

let
  version = "1.1.8";
in
buildPythonPackage {
  name = "borgmatic-${version}";

  src = fetchPyPi {
    package = "borgmatic";
    inherit version;
    sha256 = "13ac4c0fc64ee85a9afa0ce5dc4aaf9201b5f3b7f4a24cef83089f1cb4e3fb1f";
  };

  postPatch = ''
    grep -q 'ruamel.yaml<=0.15' setup.py
    sed -i 's,ruamel.yaml<=0.15,ruamel.yaml<0.16,' setup.py
  '';

  propagatedBuildInputs = [
    pykwalify
    ruamel-yaml
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

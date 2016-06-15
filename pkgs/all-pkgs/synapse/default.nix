{ stdenv
, buildPythonPackage
, fetchFromGitHub

, bleach
, blist
, canonicaljson
, daemonize
, jinja2
, matrix-angular-sdk
, netaddr
, pillow
, py-bcrypt
, pydenticon
, pymacaroons-pynacl
, pynacl
, pysaml2
, pyyaml
, service-identity
, signedjson
, twisted
, ujson
, unpaddedbase64
}:

let
  version = "0.16.0";
in
buildPythonPackage {
  name = "synapse-${version}";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = "ce03172d045a0a87b321181dea13011e14ced24664ec0511ca3382a50acec568";
  };

  propagatedBuildInputs = [
    bleach
    blist
    canonicaljson
    daemonize
    jinja2
    matrix-angular-sdk
    netaddr
    pillow
    py-bcrypt
    pydenticon
    pymacaroons-pynacl
    pynacl
    pysaml2
    pyyaml
    service-identity
    signedjson
    twisted
    ujson
    unpaddedbase64
  ];

  postPatch = ''
    sed \
      -e 's,4.0.0,5.0.0,g' \
      -e 's,0.3.0,${pynacl.version},g' \
      -i synapse/python_dependencies.py
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

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
  version = "0.16.1";
in
buildPythonPackage {
  name = "synapse-${version}";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = "f6fbf3389939805ef3e92912b59d052ead3ccfff0689ee19ec53cb8c2496487f";
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

{ stdenv
, buildPythonPackage
, fetchFromGitHub

, bleach
, blist
, canonicaljson
, daemonize
, jinja2
, jsonschema
, matrix-angular-sdk
, matrix-synapse-ldap3
, msgpack-python
, netaddr
, phonenumbers
, pillow
, psutil
, py-bcrypt
, pydenticon
, pymacaroons-pynacl
, pynacl
, pysaml2
, pyyaml
, signedjson
, twisted
, ujson
, unpaddedbase64
}:

let
  version = "0.21.1";
in
buildPythonPackage {
  name = "synapse-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = "e945ccfed06775d4b0e36ac56ea2524a7ed64694aea43fdb99563c31c6b78608";
  };

  propagatedBuildInputs = [
    bleach
    blist
    canonicaljson
    daemonize
    jinja2
    jsonschema
    matrix-angular-sdk
    matrix-synapse-ldap3
    msgpack-python
    netaddr
    phonenumbers
    pillow
    psutil
    py-bcrypt
    pydenticon
    pymacaroons-pynacl
    pynacl
    pysaml2
    pyyaml
    signedjson
    twisted
    ujson
    unpaddedbase64
  ];

  postPatch = ''
    sed \
      -e '/\(pynacl\|pysaml2\)/ s/\(,\|\)\(>\|<\|=\)\(=\|\)[0-9.]\+//g' \
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

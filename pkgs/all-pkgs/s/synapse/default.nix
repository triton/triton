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
  version = "0.20.0";
in
buildPythonPackage {
  name = "synapse-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = "8ed4f71bc674e948dbf22dad7493ce4d8c0558bfd762e76220286705e66845d0";
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

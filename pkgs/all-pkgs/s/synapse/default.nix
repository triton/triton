{ stdenv
, buildPythonPackage
, fetchFromGitHub

, affinity
, bcrypt
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
  version = "0.24.1";
in
buildPythonPackage {
  name = "synapse-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = "ffdde9a01812bf295de412fdc977d4a4ff6666e0ec5843d6f9ced0f0ef190831";
  };

  propagatedBuildInputs = [
    affinity
    bcrypt
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

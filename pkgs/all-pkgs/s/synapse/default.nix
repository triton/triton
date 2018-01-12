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
  version = "0.26.0";
in
buildPythonPackage {
  name = "synapse-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = "b8d926a26aec011851d3ca33a45824ed331b6a3433e7173ef1d3875783b9a81c";
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

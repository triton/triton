{ stdenv
, buildPythonPackage
, fetchFromGitHub

, bleach
, blist
, canonicaljson
, daemonize
, jinja2
, ldap3
, matrix-angular-sdk
, msgpack-python
, netaddr
, pillow
, psutil
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
  version = "0.18.3";
in
buildPythonPackage {
  name = "synapse-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = "d02a717de43ea9f9823a21f85d36c5d004552ca446987dcf0c02bf96e2c89a0c";
  };

  propagatedBuildInputs = [
    bleach
    blist
    canonicaljson
    daemonize
    jinja2
    ldap3
    matrix-angular-sdk
    msgpack-python
    netaddr
    pillow
    psutil
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

{ stdenv
, buildPythonPackage
, fetchFromGitHub

, bleach
, blist
, canonicaljson
, daemonize
, jinja2
, matrix-angular-sdk
, matrix-synapse-ldap3
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
, signedjson
, twisted
, ujson
, unpaddedbase64
}:

let
  version = "0.19.3";
in
buildPythonPackage {
  name = "synapse-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = "d41b81f69fd66f524e6bb338d5d96c054e53e749e8003ae8bac265233fb7f46b";
  };

  propagatedBuildInputs = [
    bleach
    blist
    canonicaljson
    daemonize
    jinja2
    matrix-angular-sdk
    matrix-synapse-ldap3
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

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
  version = "0.17.3";
in
buildPythonPackage {
  name = "synapse-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = "76191e52e87c1cf1c93d1503ad495273c4dab56ac0f01a653ddbecae2520261f";
  };

  propagatedBuildInputs = [
    bleach
    blist
    canonicaljson
    daemonize
    jinja2
    ldap3
    matrix-angular-sdk
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

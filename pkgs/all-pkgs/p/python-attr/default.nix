{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.3.1";
in
buildPythonPackage {
  name = "attr-${version}";

  src = fetchPyPi {
    package = "attr";
    inherit version;
    sha256 = "9091548058d17f132596e61fa7518e504f76b9a4c61ca7d86e1f96dbf7d4775d";
  };

  meta = with lib; {
    description = "Modules for implementing LDAP clients";
    homepage = https://www.python-ldap.org;
    license = licenses.psf-2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

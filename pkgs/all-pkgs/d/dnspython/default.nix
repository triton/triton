{ stdenv
, buildPythonPackage
, fetchPyPi

, cyrus-sasl
, openldap
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "1.15.0";
in
buildPythonPackage {
  name = "dnspython-${version}";

  src = fetchPyPi {
    package = "dnspython";
    type = ".zip";
    inherit version;
    sha256 = "40f563e1f7a7b80dc5a4e76ad75c23da53d62f1e15e6e517293b04e1f84ead7c";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

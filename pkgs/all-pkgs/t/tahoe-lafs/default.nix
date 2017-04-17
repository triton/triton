{ stdenv
, buildPythonPackage
, fetchPyPi

, characteristic
, foolscap
, nevow
, pyasn1
, pycrypto
, pycryptopp
, pyyaml
, service-identity
, simplejson
, twisted
, zfec
}:

let
  version = "1.12.1";
in
buildPythonPackage {
  name = "tahoe-lafs-${version}";

  src = fetchPyPi {
    package = "tahoe-lafs";
    inherit version;
    sha256 = "327b364a702df515fd329d49f052db0fcbf468e20c26d1f8df819f54786ca0ce";
  };

  propagatedBuildInputs = [
    characteristic
    foolscap
    nevow
    pyasn1
    pycrypto
    pycryptopp
    pyyaml
    service-identity
    simplejson
    twisted
    zfec
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, blinker
, cryptography
, pycrypto
, pyjwt

, mock
, nose
}:

let
  inherit (lib)
    optionals;

  version = "2.0.2";
in
buildPythonPackage rec {
  name = "oauthlib-${version}";

  src = fetchPyPi {
    package = "oauthlib";
    inherit version;
    sha256 = "b3b9b47f2a263fe249b5b48c4e25a5bce882ff20a0ac34d553ce43cff55b53ac";
  };

  buildInputs = optionals doCheck [
    mock
    nose
  ];

  postPatch = /* unittest2 is a backport for python <2.7 */ ''
    grep -q 'unittest2' setup.py
    sed -i setup.py \
      -e "s/'unittest2',//"
  '';

  propagatedBuildInputs = [
    blinker
    cryptography
    pycrypto
    pyjwt
  ];

  doCheck = true;

  meta = with lib; {
    description = "An implementation of the OAuth request-signing logic";
    homepage = https://github.com/idan/oauthlib;
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}

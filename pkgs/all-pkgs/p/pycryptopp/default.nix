{ stdenv
, buildPythonPackage
, fetchPyPi

, cryptopp
}:

let
  version = "0.7.1.869544967005693312591928092448767568728501330214";
in
buildPythonPackage {
  name = "pycryptopp-${version}";

  src = fetchPyPi {
    package = "pycryptopp";
    inherit version;
    sha256 = "08ad57a1a39b7ed23c173692281da0b8d49d98ad3dcc09f8cca6d901e142699f";
  };

  buildInputs = [
    #cryptopp
  ];

  configureFlags = [
    # TODO: Make work with cryptopp 8.0
    #"--disable-embedded-cryptopp"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

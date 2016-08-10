{ stdenv
, buildPythonPackage
, fetchPyPi

, pillow
}:

let
  version = "0.2";
in
buildPythonPackage {
  name = "pydenticon-${version}";

  src = fetchPyPi {
    package = "pydenticon";
    inherit version;
    sha256 = "035dawcspgjw2rksbnn863s7b0i9ac8cc1nshshvd1l837ir1czp";
  };

  buildInputs = [
    pillow
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

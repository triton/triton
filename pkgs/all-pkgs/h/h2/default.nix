{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy2
, lib

, enum34
, hpack
, hyperframe
}:

let
  version = "3.1.0";
in
buildPythonPackage {
  name = "h2-${version}";

  src = fetchPyPi {
    package = "h2";
    inherit version;
    sha256 = "fd07e865a3272ac6ef195d8904de92dc7b38dc28297ec39cfa22716b6d62e6eb";
  };

  propagatedBuildInputs = [
    hpack
    hyperframe
  ] ++ lib.optionals isPy2 [
    enum34
  ];

  meta = with lib; {
    description = "HTTP/2 for Python";
    homepage = https://github.com/python-hyper/hyper;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

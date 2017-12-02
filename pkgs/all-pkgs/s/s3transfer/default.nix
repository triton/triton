{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy2
, lib

, botocore
, futures
}:

let
  inherit (lib)
    optionals;

  version = "0.1.12";
in
buildPythonPackage rec {
  name = "s3transfer-${version}";

  src = fetchPyPi {
    package = "s3transfer";
    inherit version;
    sha256 = "10891b246296e0049071d56c32953af05cea614dca425a601e4c0be35990121e";
  };

  propagatedBuildInputs = [
    botocore
  ] ++ optionals isPy2 [
    futures
  ];

  meta = with lib; {
    description = "An Amazon S3 Transfer Manager";
    homepage = https://github.com/boto/s3transfer;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

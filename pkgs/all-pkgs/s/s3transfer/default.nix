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

  version = "0.1.13";
in
buildPythonPackage rec {
  name = "s3transfer-${version}";

  src = fetchPyPi {
    package = "s3transfer";
    inherit version;
    sha256 = "90dc18e028989c609146e241ea153250be451e05ecc0c2832565231dacdf59c1";
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

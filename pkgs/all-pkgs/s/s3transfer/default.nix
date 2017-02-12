{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy27
, lib

, botocore
, futures
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "0.1.10";
in
buildPythonPackage rec {
  name = "s3transfer-${version}";

  src = fetchPyPi {
    package = "s3transfer";
    inherit version;
    sha256 = "ba1a9104939b7c0331dc4dd234d79afeed8b66edce77bbeeecd4f56de74a0fc1";
  };

  propagatedBuildInputs = [
    botocore
  ] ++ optionals isPy27 [
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

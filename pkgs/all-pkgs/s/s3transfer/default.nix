{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy27

, botocore
, futures
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "0.1.9";
in
buildPythonPackage rec {
  name = "s3transfer-${version}";

  src = fetchPyPi {
    package = "s3transfer";
    inherit version;
    sha256 = "17ad7d672115f93a72ed7917209cb0bb02fc87f96f11886408ed8a6b1bb4c754";
  };

  propagatedBuildInputs = [
    botocore
  ] ++ optionals isPy27 [
    futures
  ];

  meta = with stdenv.lib; {
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

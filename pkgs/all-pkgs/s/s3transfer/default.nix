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

  version = "0.1.6";
in
buildPythonPackage rec {
  name = "s3transfer-${version}";

  src = fetchPyPi {
    package = "s3transfer";
    inherit version;
    sha256 = "7bff7d99c96cb7573781b3dfcc5148cab5196f46c5c43f045e3c4f29a10a212a";
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

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

  version = "0.1.3";
in
buildPythonPackage rec {
  name = "s3transfer-${version}";

  src = fetchPyPi {
    package = "s3transfer";
    inherit version;
    sha256 = "af2e541ac584a1e88d3bca9529ae784d2b25e5d448685e0ee64f4c0e1e017ed2";
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

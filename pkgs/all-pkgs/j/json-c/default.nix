{ stdenv
, autoconf
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "json-c-0.13";

  src = fetchurl {
    url = "https://s3.amazonaws.com/json-c_releases/releases/${name}-nodoc.tar.gz";
    multihash = "QmXX4CdLoBynvztrGnqwYvBsYwHtJBRBLK3QQRNwTZBLqV";
    sha256 = "8572760646e9d23ee68f967ca62fa134a97b931665fd9af562192b7788c95a06";
  };

  nativeBuildInputs = [
    autoconf
  ];

  configureFlags = [
    "--enable-threading"
    "--enable-rdrand"
  ];

  meta = with stdenv.lib; {
    description = "A JSON implementation in C";
    homepage = https://github.com/json-c/json-c/wiki;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

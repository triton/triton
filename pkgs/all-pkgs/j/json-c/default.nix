{ stdenv
, autoconf
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "json-c-0.13.1";

  src = fetchurl {
    url = "https://s3.amazonaws.com/json-c_releases/releases/${name}-nodoc.tar.gz";
    multihash = "QmcZKHLKKMKbQH3Gm7C57LnskNGCcvSJNDRyahiKSjib9X";
    sha256 = "94a26340c0785fcff4f46ff38609cf84ebcd670df0c8efd75d039cc951d80132";
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

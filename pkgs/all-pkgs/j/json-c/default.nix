{ stdenv
, autoconf
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "json-c-0.12.1";

  src = fetchurl {
    url = "https://s3.amazonaws.com/json-c_releases/releases/${name}-nodoc.tar.gz";
    multihash = "QmYuLUUv4TTfurajXeMsRAYTw5aJbmutgdDr1jFTga5B1H";
    sha256 = "5a617da9aade997938197ef0f8aabd7f97b670c216dc173977e1d56eef9e1291";
  };

  nativeBuildInputs = [
    autoconf
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

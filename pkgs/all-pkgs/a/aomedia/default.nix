{ stdenv
, cmake
, fetchgit
, lib
, nasm
, ninja
, perl
, python3

, channel ? "stable"
}:

let
  sources = {
    stable = {
      fetchzipversion = 6;
      version = "1.0.0";
      sha256 = "0263dc1ae78af2b59173c3d86a8b0a1fce568f140dc71ed3a01820260438f0e6";
    };
    head = {
      fetchzipversion = 6;
      version = "2019-02-15";
      rev = "eaf8063f1e043cd7bd60329ef06e49920d920308";
      sha256 = "97a8a4fcccd89674f515560a5454fe15894339f7aaae459956bb65d232802e0c";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "aomedia-${source.version}";

  src = fetchgit {
    version = source.fetchzipversion;
    url = "https://aomedia.googlesource.com/aom";
    rev =
      if channel != "head" then
        "refs/tags/v${source.version}"
      else
        source.rev;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    cmake
    nasm
    ninja
    perl
    python3
  ];

  cmakeFlags = [
    "-DENABLE_DOCS=OFF"
    "-DENABLE_NASM=ON"
    "-DBUILD_SHARED_LIBS=ON"
  ];

  meta = with lib; {
    description = "AV1 Codec Library";
    homepage = http://aomedia.org/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

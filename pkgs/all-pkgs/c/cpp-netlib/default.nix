{ stdenv
, cmake
, fetchurl
, ninja

, boost
, openssl
}:

let
  version = "0.12.0";
in
stdenv.mkDerivation rec {
  name = "cpp-netlib-${version}";

  src = fetchurl {
    url = "http://downloads.cpp-netlib.org/${version}/${name}-final.tar.bz2";
    multihash = "QmPJqo17ER9EoE9MjzKV78e29w2fSQnsnJZtToVPvRKEWW";
    sha256 = "088ef9ff8f0e402a634d4d9529ae450d8af965988866242df34dd59157f6ef40";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    boost
    openssl
  ];

  cmakeFlags = [
    "-DCPP-NETLIB_BUILD_SHARED_LIBS=ON"
    "-DCPP-NETLIB_BUILD_TESTS=OFF"
    "-DCPP-NETLIB_BUILD_EXAMPLES=OFF"
  ];

  # Cleanup some import paths that are broken
  preFixup = ''
    grep -r '<asio/[^>]*>' "$out/include" | awk -F: '{print $1}' | sort | uniq \
      | xargs -n 1 -P $NIX_BUILD_CORES sed -i 's,<asio/\([^>]*\)>,<boost/asio/\1>,g'
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

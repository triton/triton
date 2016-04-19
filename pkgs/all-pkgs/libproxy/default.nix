{ stdenv
, cmake
, fetchFromGitHub
, ninja

, glib
, zlib
}:

let
  version = "0.4.12";
in
stdenv.mkDerivation rec {
  name = "libproxy-${version}";

  src = fetchFromGitHub {
    owner = "libproxy";
    repo = "libproxy";
    rev = version;
    sha256 = "845dc3a4f29349a9e62c0235e79fc753115fd519f2e4857aaa0f4c2503e59994";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    glib
    zlib
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

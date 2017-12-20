{ stdenv
, lib
, cmake
, fetchFromGitHub
, ninja

, libconfig
, openssl
, protobuf-c
}:

let
  date = "2017-08-28";
  rev = "55689f8918dde299c47c06eee4b8eda4a1c9889e";
in
stdenv.mkDerivation {
  name = "umurmur-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "umurmur";
    repo = "umurmur";
    inherit rev;
    sha256 = "9218fea702d0380aab1721fdb31b4050def075736512a1869787c0c67af3d6f6";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libconfig
    openssl
    protobuf-c
  ];
  
  cmakeFlags = [
    "-DSSL=openssl"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

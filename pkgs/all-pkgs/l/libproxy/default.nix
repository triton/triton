{ stdenv
, cmake
, fetchFromGitHub

, glib
, zlib
}:

let
  version = "0.4.15";
in
stdenv.mkDerivation rec {
  name = "libproxy-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "libproxy";
    repo = "libproxy";
    rev = version;
    sha256 = "09bbe39a15ec4fe7be6293e8ea3a15a3ef2d71e38f5e9b4f551c85db715aed05";
  };

  nativeBuildInputs = [
    cmake
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

{ stdenv
, cmake
, fetchurl
, ninja

, glib
, zlib
}:

let
  version = "0.4.15";
in
stdenv.mkDerivation rec {
  name = "libproxy-${version}";

  src = fetchurl {
    url = "https://github.com/libproxy/libproxy/releases/download/${version}/${name}.tar.xz";
    sha256 = "654db464120c9534654590b6683c7fa3887b3dad0ca1c4cd412af24fbfca6d4f";
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

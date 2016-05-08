{ stdenv
, cmake
, fetchFromGitHub
, ninja
, perl

, db
}:

stdenv.mkDerivation rec {
  name = "libical-${version}";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "libical";
    repo = "libical";
    rev = "v${version}";
    sha256 = "a8e452c7f5bd762aeccbc500b264f86cc802a1fb15d5e6f862b8279d0e521c4d";
  };

  nativeBuildInputs = [
    cmake
    ninja
    perl
  ];

  buildInputs = [
    db
  ];

  cmakeFlags = [
    "-DWITH_BDB=YES"
  ];

  meta = with stdenv.lib; {
    homepage = https://github.com/libical/libical;
    description = "an Open Source implementation of the iCalendar protocols";
    license = licenses.mpl10;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

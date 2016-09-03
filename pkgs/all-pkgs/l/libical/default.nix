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
    version = 1;
    owner = "libical";
    repo = "libical";
    rev = "v${version}";
    sha256 = "4432bbe74cbc778f8d40df4d1d419a8154f2ccd329508cd55f267d2622e7f75a";
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

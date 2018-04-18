{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
}:

let
  version = "2018-03-21";
in
stdenv.mkDerivation rec {
  name = "fribidi-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "fribidi";
    repo = "fribidi";
    rev = "47ed4eb33d11ff132d698decd24be4e16ff55c60";
    sha256 = "9b41531bff1fba6bf692545d586e9def0b4be443ca6439ccd03770907a6e19ee";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  mesonFlags = [
    "-Ddocs=false"
  ];

  meta = with lib; {
    description = "GNU implementation of the Unicode Bidirectional Algorithm";
    homepage = https://github.com/fribidi/fribidi;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

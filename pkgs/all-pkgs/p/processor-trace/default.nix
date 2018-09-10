{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "2.0";
in
stdenv.mkDerivation {
  name = "processor-trace-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "01org";
    repo = "processor-trace";
    rev = "v${version}";
    sha256 = "374c950e24330b1cff41f8d73424177bd6aee5624e5328d80d3165985e108569";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DSIDEBAND=ON"
    "-DPEVENT=ON"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

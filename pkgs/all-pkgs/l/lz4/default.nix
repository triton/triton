{ stdenv
, fetchFromGitHub
}:

let
  version = "1.8.0";
in
stdenv.mkDerivation rec {
  name = "lz4-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "lz4";
    repo = "lz4";
    rev = "v${version}";
    sha256 = "f69f9004072636f0e9575da7c3dd87b89c04e77d6d9e7a8ae6fa0330506065c6";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  parallelBuild = false;

  meta = with stdenv.lib; {
    description = "Extremely fast compression algorithm";
    homepage = https://code.google.com/p/lz4/;
    license = with licenses; [ bsd2 gpl2Plus ];
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

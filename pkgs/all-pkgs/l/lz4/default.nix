{ stdenv
, fetchFromGitHub
}:

let
  version = "1.8.2";
in
stdenv.mkDerivation rec {
  name = "lz4-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "lz4";
    repo = "lz4";
    rev = "v${version}";
    sha256 = "7c052ef43e0fd7f2b1c81b1e2909b323becef9b110ecf58d60c5d925f162dec2";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  buildParallel = false;

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

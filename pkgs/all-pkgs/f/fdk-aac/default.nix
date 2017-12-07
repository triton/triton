{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib

# Example encoding program
, exampleSupport ? false

, channel
}:

let
  inherit (lib)
    boolEn
    optionals;

  sources = {
    "stable" = rec {
      fetchzipverion = 2;
      version = "0.1.5";
      rev = "v${version}";
      sha256 = "e2fdeb17d045e15cf57cd2689deca4ff7d0ad18cd4cdf9e400ff2664f3c91cf8";
    };
    "head" = {
      fetchzipverion = 3;
      version = "2017-11-20";
      rev = "56c717e223a161b11f523de97dae51c5cccd6b52";
      sha256 = "7b2866d33d0c012b2817fa34da9c8a77c828d8078745b7ee95e938c12a972da3";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "fdk-aac-${source.version}";

  src = fetchFromGitHub {
    version = source.fetchzipverion;
    owner = "mstorsjo";
    repo = "fdk-aac";
    inherit (source) rev sha256;
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  configureFlags = [
    "--${boolEn exampleSupport}-example"
  ];

  meta = with lib; {
    description = "An implementation of the AAC codec from Android";
    homepage = http://sourceforge.net/projects/opencore-amr/;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

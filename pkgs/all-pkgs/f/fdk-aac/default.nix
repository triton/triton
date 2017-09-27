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
      version = "2017-09-20";
      rev = "e2e35b82738dc9d5e5229477d49d557cadad4dc7";
      sha256 = "1e0ffb7262e425afd9b1ac3d5c7b43ff6992c0bd1d9904b80a5884d088ed2316";
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

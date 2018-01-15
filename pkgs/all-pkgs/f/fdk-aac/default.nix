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
      fetchzipverion = 5;
      version = "2017-12-20";
      rev = "89aeea5f292306c429550e4c9fe55d865c903600";
      sha256 = "9883e4b97a46fc9a6ff67c5ea8ace3ffb9d859a59e4ff071e273ec9df6dd1431";
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

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
      version = "2017-06-22";
      rev = "af5863a78efdfccd003dd6bea68c4a2cd2ad9f37";
      sha256 = "2c0d90dd79d12fceda6f7fccfc0d0d4033a3c110a071f97e02898dea61db7cd0";
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

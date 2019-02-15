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
      version = "0.1.6";
      rev = "v${version}";
      sha256 = "18c71799b1f8e8d48660b19f6a5cb67ced38811b31b9ae6588f23a2a4ee98a94";
    };
    "head" = {
      fetchzipverion = 6;
      version = "2019-01-30";
      rev = "95858d7bd36f19bde4a9595e2bd68f195215b164";
      sha256 = "34230460ac5a0d5777fb3b4e9539f229b77d405b770a9c66a458b9932ee2fc39";
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

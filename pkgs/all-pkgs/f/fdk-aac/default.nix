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
      fetchzipverion = 5;
      version = "2018-03-06";
      rev = "a30bfced6b6d6d976c728552d247cb30dd86e238";
      sha256 = "06d9b688c6cab00abc7ad54b250052d766f94168faec4a615421a02272d41b40";
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

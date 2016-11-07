{ stdenv
, autoreconfHook
, fetchFromGitHub
, fetchurl
, lib

# Example encoding program
, exampleSupport ? false

, channel
}:

let
  inherit (lib)
    boolEn
    optionals;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "fdk-aac-${source.version}";

  src = (
    if channel == "head" then
      fetchFromGitHub {
        version = source.fetchzipverion;
        owner = "mstorsjo";
        repo = "fdk-aac";
        inherit (source) rev sha256;
      }
    else
      fetchurl {
        url = "mirror://sourceforge/opencore-amr/fdk-aac/${name}.tar.gz";
        inherit (source) sha256;
      }
  );

  nativeBuildInputs = optionals (channel == "head") [
    autoreconfHook
  ];

  configureFlags = [
    "--${boolEn exampleSupport}-example"
  ];

  # Remove for > 0.1.4
  CXXFLAGS = optionals (channel == "stable") [
    "-std=c++03"
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

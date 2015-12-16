{ stdenv, fetchurl, pkgconfig, cmake }:

stdenv.mkDerivation rec {
  version = "1.3.3";
  name = "graphite2-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/silgraphite/graphite2/${name}.tgz";
    sha256 = "1n22vvi4jl83m4sqhvd7v31bhyhyd8j6c3yjgh4zjfyrvid16jrg";
  };

  nativeBuildInputs = [ pkgconfig cmake ];

  patches = stdenv.lib.optionals stdenv.isDarwin [ ./macosx.patch ];

  meta = {
    description = "An advanced font engine";
    maintainers = [ stdenv.lib.maintainers.raskin ];
    hydraPlatforms = stdenv.lib.platforms.unix;
  };
}

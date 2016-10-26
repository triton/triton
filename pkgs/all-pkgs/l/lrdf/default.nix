{ stdenv
, autoreconfHook
, fetchurl

, ladspa-sdk
, openssl
, raptor2
}:

let
  version = "0.5.0";
in
stdenv.mkDerivation rec {
  name = "lrdf-${version}";

  src = fetchurl {
    url = "https://github.com/swh/LRDF/archive/${version}.tar.gz";
    sha256 = "ba803af936fd53a8b31651043732e6d6cec3d24fa24d2cb8c1506c2d1675e2a2";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    ladspa-sdk
    openssl
    raptor2
  ];

  preAutoreconf = "rm m4/*";

  meta = with stdenv.lib; {
    description = "RDF library with support for LADSPA plugins";
    homepage = http://sourceforge.net/projects/lrdf/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

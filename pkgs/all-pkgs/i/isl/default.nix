{ stdenv
, fetchurl

, gmp

, channel
}:

let
  sources = {
    "0.20" = {
      version = "0.20";
      multihash = "QmX4H1gPmNoYiZQ4WYyJspr3PyUmw2W2vsaytzDocoGgyr";
      sha256 = "a5596a9fb8a5b365cb612e4b9628735d6e67e9178fae134a816ae195017e77aa";
    };
  };

  inherit (sources."${channel}")
    multihash
    sha256
    version;
in
stdenv.mkDerivation rec {
  name = "isl-${version}";

  src = fetchurl {
    url = "http://isl.gforge.inria.fr/${name}.tar.xz";
    inherit multihash sha256;
  };

  buildInputs = [
    gmp
  ];

  configureFlags = [
    "--disable-silent-rules"
    "--enable-portable-binary"
  ];

  # For some reason the binaries built during the build process
  # don't maintain references to libgmp. This is a workaround to
  # make the build work.
  preBuild = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -lgmp"
  '';

  # Ensure we don't depend on anything unexpected
  allowedReferences = [
    "out"
    stdenv.cc.libc
    gmp
  ];

  meta = with stdenv.lib; {
    homepage = http://www.kotnet.org/~skimo/isl/;
    description = "A library for manipulating sets and relations of integer points bounded by linear constraints";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

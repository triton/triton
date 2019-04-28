{ stdenv
, fetchurl

, gmp

, channel
}:

let
  sources = {
    "0.21" = {
      version = "0.21";
      multihash = "QmYhgCGiiUuUKahh3uugJyrsMSQ1wVXs16WvD5mDjxL9ui";
      sha256 = "777058852a3db9500954361e294881214f6ecd4b594c00da5eee974cd6a54960";
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
    gmp
  ] ++ stdenv.cc.runtimeLibcLibs;

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

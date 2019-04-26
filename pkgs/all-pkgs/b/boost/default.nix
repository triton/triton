{ stdenv
, fetchurl
, lib

, bzip2
, icu
, xz
, zlib
, zstd

, channel
}:

let
  sources = {
    "1.66" = {
      version = "1.66.0";
      sha256 = "5721818253e6a0989583192f96782c4a98eb6204965316df9f5ad75819225ca9";
    };
    "1.70" = {
      version = "1.70.0";
      sha256 = "430ae8354789de4fd19ee52f3b1f739e1fba576f0aded0897c3c2bc00fb38778";
    };
  };
  inherit (lib)
    optionals
    replaceStrings
    versionAtLeast;

  inherit (sources."${channel}")
    version
    sha256;
in
stdenv.mkDerivation {
  name = "boost-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/boost/boost/${version}/"
      + "boost_${replaceStrings ["."] ["_"] version}.tar.bz2";
    inherit sha256;
  };

  buildInputs = [
    bzip2
    icu
    xz
    zlib
  ] ++ optionals (versionAtLeast version "1.68.0") [
    zstd
  ];

  configurePhase = ''
    ./bootstrap.sh --prefix="$dev"
  '';

  b2Args = [
    "variant=release"
    "threading=multi"
    "link=shared"
    "runtime-link=shared"
  ];

  buildPhase = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $lib"
    b2Args="$b2Args -j$NIX_BUILD_CORES"

    ./b2 $b2Args
  '';

  installPhase = ''
    ./b2 $b2Args install

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib/*.so* "$lib"/lib
    rm -r "$dev"/lib

    mkdir -p "$dev"/nix-support
    echo "$lib" >"$dev"/nix-support/propagated-native-build-inputs
  '';

  preFixup = ''
    # We don't ever want full directory references to boost
    # TODO: Make this a common fixup
    cd "$dev"/include
    find . -type f -exec sed -i '1i#line 1 "{}"' {} \;
  '';

  outputs = [
    "dev"
    "lib"
  ];

  meta = with lib; {
    homepage = "http://boost.org/";
    description = "Collection of C++ libraries";
    license = licenses.boost;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

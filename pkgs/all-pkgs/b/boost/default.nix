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
    "1.71" = {
      version = "1.71.0";
      sha256 = "d73a8da01e8bf8c7eda40b4c84915071a8c8a0df4a6734537ddde4a8580524ee";
    };
  };
  inherit (lib)
    optionals
    replaceStrings
    versionAtLeast;

  inherit (sources."${channel}")
    version
    sha256;

  srcFile = "boost_${replaceStrings ["."] ["_"] version}.tar.bz2";
in
stdenv.mkDerivation {
  name = "boost-${version}";

  src = fetchurl {
    urls = [
      "https://dl.bintray.com/boostorg/release/${version}/source/${srcFile}"
      "mirror://sourceforge/boost/boost/${version}/${srcFile}"
    ];
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
    "link=static,shared"
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
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
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

  passthru = {
    inherit version;
  };

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

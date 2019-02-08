{ stdenv
, fetchurl
, lib
, pkgs

, python

, channel
}:

let
  boost = pkgs.boost.override { inherit channel; };
in
stdenv.mkDerivation {
  name = python.libPrefix + "-" + boost.name;

  inherit (boost)
    src;

  buildInputs = [
    python
  ];

  configurePhase = ''
    ./bootstrap.sh --prefix="$dev" --with-python="${python.executable}"
  '';

  b2Args = [
    "variant=release"
    "threading=multi"
    "link=shared"
    "runtime-link=shared"
    "--with-python"
  ];

  buildPhase = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $lib"
    b2Args="$b2Args -j$NIX_BUILD_CORES"

    ./b2 $b2Args
  '';

  installPhase = ''
    ./b2 $b2Args install

    rm -r "$dev"/include

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib/*.so* "$lib"/lib
    rm -r "$dev"/lib

    mkdir -p "$dev"/nix-support
    echo "$lib ${boost.dev}" >"$dev"/nix-support/propagated-native-build-inputs
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

{ stdenv
, fetchurl
, lib
, pkgs

, python

, channel
}:

let
  boost = pkgs.boost.override { inherit channel; };
  pythonMajor = lib.head (lib.splitString "." python.version);
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
  '' + lib.optionalString (lib.versionAtLeast boost.version "1.67.0") ''
    # Autoconf archive does not detect python minor versions correctly.
    ln -sv "$lib"/lib/libboost_python${if python.isPy2 then "" else pythonMajor}*.so \
      "$lib"/lib/libboost_python${if python.isPy2 then "" else pythonMajor}.so
  '' + ''
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

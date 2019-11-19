{ stdenv
, cc
, fetchurl
, gcc
, gcc_lib
, lib
}:

let
  inherit (lib)
    filter;
in
stdenv.mkDerivation rec {
  name = "libstdcxx-${gcc.version}";

  src = gcc.src;

  patches = gcc.patches;

  nativeBuildInputs = [
    cc
  ];

  configureFlags = gcc.commonConfigureFlags;

  preConfigure = ''
    # We need to avoid linking stdc++ by using the gcc executable for c++ code
    export CXX="$CC"

    mkdir -v build
    cd build
    tar xf '${gcc_lib.internal}'/build.tar.xz
    find . -type f -exec sed -i "s,/build-dir,$NIX_BUILD_TOP,g" {} \;
    mkdir -p $NIX_SYSTEM_HOST/libstdc++-v3
    cd $NIX_SYSTEM_HOST/libstdc++-v3
    configureScript='../../../libstdc++-v3/configure'
    chmod +x "$configureScript"
  '';

  postInstall = ''
    rm -r "$dev"/share

    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    mv "$lib"/lib/*.py "$dev"/lib
    ln -sv "$lib"/lib/* "$dev"/lib

    mkdir -p "$dev"/nix-support
    cxxinc="$(dirname "$(dirname "$dev"/include/c++/*/*/bits/c++config.h)")"
    echo "-idirafter $(dirname "$cxxinc")" >>"$dev"/nix-support/stdincxx
    echo "-idirafter $cxxinc" >>"$dev"/nix-support/stdincxx
    echo "-L$dev/lib" >>"$dev"/nix-support/ldflags
  '';

  outputs = [
    "dev"
    "lib"
  ];

  outputChecks = {
    dev.allowedReferences = [ "dev" "lib" ] ++ filter (n: n != null) (map (n: n.dev or null) cc.inputs);
    lib.allowedReferences = [ ] ++ filter (n: n != null) (map (n: n.lib or null) cc.inputs);
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}

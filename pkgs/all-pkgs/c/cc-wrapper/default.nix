{ stdenv
, cc
, fetchurl
, gnumake
, gnutar
, lib
}:

let
  hostCc = cc;
in

{ cc
, libc
, outputSystem ? (cc.outputSystem or stdenv.targetSystem)
, wrappedPackages ? [ ]
}:

let
  inherit (lib)
    any
    concatMapStrings
    concatStringsSep
    head
    optionalString
    optionals;
  inherit (lib.platforms)
    i686-linux
    x86_64-linux;

  platformTuples = {
    "${head x86_64-linux}" = "x86_64-pc-linux-gnu";
    "${head x86_64-linux}-boot" = "x86_64-nixboot-linux-gnu";
    "${head i686-linux}" = "i686-pc-linux-gnu";
    "${head i686-linux}-boot" = "i686-nixboot-linux-gnu";
  };

  outputTuple = platformTuples."${outputSystem}";

  buildInputs = [
    cc
  ] ++ wrappedPackages;

  binDirList = map (n: "${n.bin or n}/bin") buildInputs;
in
stdenv.mkDerivation {
  name = "cc-wrapper";

  src = ./src.tar;

  nativeBuildInputs = [
    gnumake
    gnutar
    hostCc
  ];

  inherit buildInputs;

  postPatch = ''
    echo "Patching /usr/bin/env shebangs"
    find "$srcRoot" -name \*.sh -or -name configure -type f | xargs sed -i "1i#! $bash"
  '';

  TARGET_PATH = concatStringsSep ":" binDirList;
  TARGET_COMPILER = "gcc";
  TARGET_LINKER = "binutils";
  TARGET_ARCH = optionalString (hostCc != null) outputTuple;

  preConfigure = ''
    export TARGET_DL=$(find "${libc.lib or libc}/lib/" -name ld\*.so\* -exec readlink -f {} \; | head -n 1)
    test -n "$TARGET_DL"
    export TARGET_LIBC_INCLUDE="${libc.dev or libc}/include"
  '';

  configureAction = ''
    pushd "$srcRoot" >/dev/null
    PREFIX="$out" ./configure
    popd >/dev/null
  '';

  postInstall = ''
    source '${./lib.sh}'
    deepLink '${cc.dev or cc}'/lib/gcc/*/* "$out"
    deepLink '${cc.bin or cc}'/libexec/gcc/*/* "$out"
    mkdir -p "$out"/include
    ln -sv "$(readlink -f '${cc.dev or cc}'/include/c++)" "$out"/include/c++
    libs=(
      '${libc.lib or libc}'/lib/*.o
      '${libc.lib or libc}'/lib/*.so*
      '${cc.lib or cc}'/lib/*.so*
    )
    for lib in "''${libs[@]}"; do
      ln -sv $(readlink -f "$lib") "$out"/lib/$(basename "$lib") 2>/dev/null || true
    done

    for file in ${concatMapStrings (n: "'${n}'/* ") binDirList}; do
      if [ -e "$out/bin/$(basename "$file")" ]; then
        continue
      fi
      ln -sv "$file" "$out"/bin
    done
  '';

  doInstallCheck = true;

  installCheckAction = ''
    pushd "$TMPDIR" >/dev/null

    # Test that our compiler works as expected
    echo "#include <stdlib.h>" >main.c
    echo "int main() { return EXIT_SUCCESS; }" >>main.c
    env -i CC_WRAPPER_LOG_LEVEL=debug "$out"/bin/gcc -v -o main main.c
    ./main

    echo "#include <cstdlib>" >main.cc
    echo "int main() { return EXIT_SUCCESS; }" >>main.cc
    env -i CC_WRAPPER_LOG_LEVEL=debug "$out"/bin/g++ -v -o main main.cc
    ./main

    popd >/dev/null
  '';

  passthru = {
    inherit
      cc
      libc
      platformTuples;
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
  };
}

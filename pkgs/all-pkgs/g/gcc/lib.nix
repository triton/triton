{ stdenv
, cc
, fetchurl
, gcc
, lib

, type ? null
}:

let
  inherit (lib)
    filter
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "libgcc${optionalString (type != null) "-${type}"}-${gcc.version}";

  inherit (gcc)
    src
    patches;

  nativeBuildInputs = [
    cc
  ];

  configureFlags = gcc.commonConfigureFlags ++ optionals (type == "nolibc") [
    "--disable-gcov"
  ];

  disableShared = type == "nolibc";

  postPatch = ''
    # Extract headers from the gcc build and use them
    mkdir -v build
    cd build
    tar xf '${gcc.internal}'/build.tar.xz
    find . -type f -exec sed -i "s,/build-dir,$NIX_BUILD_TOP,g" {} \;

    # We are guaranteed to have libc headers so use them
    grep -q '\-Dinhibit_libc' gcc/libgcc.mvars
    sed -i 's, -Dinhibit_libc,,g' gcc/libgcc.mvars

    mkdir -p $NIX_SYSTEM_HOST/libgcc
    cd $NIX_SYSTEM_HOST/libgcc
    configureScript='../../../libgcc/configure'
    chmod +x "$configureScript"
  '';

  postInstall = ''
    mv -v "$dev"/lib/gcc/*/*/* "$dev"/lib
    rm -r "$dev"/lib/gcc

    mv "$dev"/lib/include "$dev"

    mkdir -p "$lib"/lib
    for file in "$dev"/lib*/*; do
      if [[ "$file" == *.so* ]] && isELF "$file"; then
        mv "$file" "$lib"/lib
      fi
    done
    ln -sv "$lib"/lib/* "$dev"/lib

    mkdir -p "$dev"/nix-support
    echo "-B$dev/lib" >>"$dev"/nix-support/cflags
    echo "-idirafter $dev/include" >>"$dev"/nix-support/stdinc
    echo "-L$dev/lib" >>"$dev"/nix-support/ldflags
  '' + optionalString (type != "nolibc") ''
    find . -not -type d -and -not -name '*'.h -delete
    find . -type f -exec sed -i "s,$NIX_BUILD_TOP,/build-dir,g" {} \;
    mkdir -p "$internal"
    cd ../..
    tar Jcf "$internal"/build.tar.xz $NIX_SYSTEM_HOST/libgcc
  '' + optionalString (type == "nolibc") ''
    # GCC will pull in gcc_eh during linking, but a libc shouldn't need
    # the exception handling symbols
    ln -sv libgcc.a "$dev"/lib/libgcc_eh.a
  '';

  outputs = [
    "dev"
    "lib"
  ] ++ optionals (type != "nolibc") [
    "internal"
  ];

  outputChecks = {
    dev.allowedReferences = [ "dev" "lib" ] ++ filter (n: n != null) (map (n: n.dev or null) cc.inputs);
    lib.allowedReferences = [ ] ++ filter (n: n != null) (map (n: n.lib or null) cc.inputs);
    internal.allowedReferences = [ ];
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

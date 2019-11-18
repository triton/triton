{ stdenv
, lib
, cc
, fetchurl
, fetchTritonPatch
}:

let
  inherit (lib)
    hasPrefix
    optionalString
    optionals;

  version = "1.1.24";
in
(stdenv.override { cc = null; }).mkDerivation rec {
  name = "musl-${version}";

  src = fetchurl {
    url = "https://www.musl-libc.org/releases/${name}.tar.gz";
    multihash = "QmT6j4ASw3xhXSMrdoN2tRuNz9E9ZgsaDU5DuV9XfXt3VE";
    hashOutput = false;
    sha256 = "1370c9a812b2cf2a7d92802510cca0058cc37e66a7bedd70051f0a34015022a3";
  };

  nativeBuildInputs = [
    cc
  ];

  patches = optionals (stdenv.targetSystem == "powerpc64le-linux") [
    #(fetchTritonPatch {
    #  rev = "1b8396502775c93dfe8916cbfdc90c9265d6bfbd";
    #  file = "m/musl/0001-powerpc64-add-IEEE-binary128-long-double-support.patch";
    #  sha256 = "68e4fbec40859cbd0f01a04a841664f6016242e2467b26f0d5e5915061ecb382";
    #})
  ];

  postPatch = ''
    sed -i '/-m\(arch\|tune\)=/s,.*,true,' configure
  '';

  preBuild = ''
    $CC -c -o ssp.o '${./ssp.c}'
    $AR rcs libssp_nonshared.a ssp.o
  '';

  postInstall = ''
    mkdir -p "$lib"/lib
    mv "$dev"/lib/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib

    mkdir -p "$bin"/bin
    ln -sv "$lib"/lib/libc.so "$bin"/bin/ldd

    cp libssp_nonshared.a "$dev"/lib
    rm "$dev"/lib/libc.so
    sed "s,@lib@,$lib,g" '${./libc.so.in}' >"$dev"/lib/libc.so

    mkdir -p "$dev"/nix-support
    echo "-fno-strict-overflow" >>"$dev"/nix-support/cflags-before
    echo "-fstack-protector-strong" >>"$dev"/nix-support/cflags-before
    echo "-idirafter $dev/include" >"$dev"/nix-support/stdinc
    echo "-B$dev/lib" >"$dev"/nix-support/cflags-link
    echo -n "$lib/lib/libc.so" >>"$dev"/nix-support/dynamic-linker
    echo "--enable-new-dtags" >>"$dev"/nix-support/ldflags-before
    echo "-z noexecstack" >>"$dev"/nix-support/ldflags-before
    echo "-z now" >>"$dev"/nix-support/ldflags-before
    echo "-z relro" >>"$dev"/nix-support/ldflags-before
    echo "-L$dev/lib" >"$dev"/nix-support/ldflags
  '' + optionalString (stdenv.targetSystem == "powerpc64le-linux") ''
    # TODO: Make 128-bit floats work
    #echo "-Wno-psabi" >>"$dev"/nix-support/cflags-before
    #echo "-mlong-double-128" >>"$dev"/nix-support/cflags-before
    #echo "-mabi=ieeelongdouble" >>"$dev"/nix-support/cflags-before
    echo "-mlong-double-64" >>"$dev"/nix-support/cflags-before
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ];

  allowedReferences = outputs;

  passthru = {
    inherit version;
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "8364 8929 0BB6 B70F 99FF  DA05 56BC DB59 3020 450F";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "An efficient, small, quality libc implementation";
    homepage = "http://www.musl-libc.org";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      powerpc64le-linux
      ++ i686-linux
      ++ x86_64-linux;
  };
}

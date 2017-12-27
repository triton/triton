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
in
stdenv.mkDerivation {
  name = "cc-wrapper";

  src = ./src.tar;

  nativeBuildInputs = [
    gnumake
    gnutar
  ];

  propagatedBuildInputs = [
    cc
  ] ++ wrappedPackages;

  postPatch = ''
    echo "Patching /usr/bin/env shebangs"
    find "$srcRoot" -name \*.sh -or -name configure -type f | xargs sed -i "1i#! $bash"
  '';

  TARGET_PATH = concatStringsSep ":" (map (n: "${n}/bin") ([ cc ] ++ wrappedPackages));
  TARGET_COMPILER = "gcc";
  TARGET_LINKER = "binutils";
  TARGET_ARCH = optionalString (hostCc != null) outputTuple;

  CFLAGS = optionals (hostCc == null) [
    "-idirafter" "${libc.dev or libc}/include"
  ];

  preConfigure = ''
    type -P cc && export CC="cc" || true
    type -P gcc && export CC="gcc" || true
    type -P clang && export CC="clang" || true

    export CFLAGS="$CFLAGS -idirafter $(echo ${cc.dev or cc}/lib/gcc/*/*/include-fixed)"
  '';

  configureAction = ''
    pushd "$srcRoot" >/dev/null
    PREFIX="$out" ./configure
    popd >/dev/null
  '';

  passthru = {
    inherit platformTuples;
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
  };
}

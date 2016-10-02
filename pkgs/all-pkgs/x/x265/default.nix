{ stdenv
, cmake
, fetchurl
, ninja
, yasm

, numactl

# Optionals
, cliSupport ? true # Build standalone CLI application

, unittestsSupport ? false # Unit tests

# Debugging options
, debugSupport ? false # Run-time sanity checks (debugging)
, werrorSupport ? false # Warnings as errors
, custatsSupport ? false # Internal profiling of encoder work
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    boolOn
    concatStringsSep
    elem
    optionals
    platforms;

  version = "2.1";

  src = fetchurl {
    url = "https://bitbucket.org/multicoreware/x265/downloads/"
      + "x265_${version}.tar.gz";
    multihash = "QmW92vUhh1nXAkV5GkdB7aXYhVFi4P7NY4SUDP8NXeEZZT";
    sha256 = "b3bc83754e91ed5655c8cba5a2ed48e6b9ab39699c9ed6554c670211d5870f9c";
  };

  cmakeFlagsAll = [
    "-DCHECKED_BUILD=${boolOn debugSupport}"
    "-DENABLE_AGGRESSIVE_CHECKS=OFF"
    "-DENABLE_ASSEMBLY=ON"
    "-DENABLE_LIBNUMA=${boolOn (
      elem targetSystem platforms.linux
      && numactl != null)}"
    "-DENABLE_PIC=ON"
    "-DENABLE_PPA=OFF"
    "-DENABLE_TESTS=OFF"
    "-DENABLE_VTUNE=OFF"
    "-DWARNINGS_AS_ERRORS=OFF"
  ];
in

assert (elem targetSystem platforms.linux) -> numactl != null;

/* By default, the compiled library is configured for only one
 * output bit depth.  Meaning, one has to rebuild libx265 if they
 * want to produce HEVC files with a different bit depth, which
 * is annoying.  However, upstream supports proper namespacing
 * for 8bit, 10bit & 12bit HEVC and linking all that together so
 * that the resulting library can produce all three of bit depths
 * instead of only one.  The API requires the bit depth parameter,
 * so that libx265 can then chose which variant of the encoder to use.  To
 * achieve this, we have to build one (static) library for each
 * non-main variant, and link it into the main library.  Upstream
 * documents using the 8bit variant as main library, hence we do not
 * allow disabling it: "main" *MUST* come last in the following list.
 */
let
  libx265-10 = stdenv.mkDerivation {
    name = "libx265-10-${version}";

    inherit src;

    cmakeFlags = [
      "-DENABLE_CLI=OFF"
      "-DENABLE_SHARED=OFF"
      "-DEXPORT_C_API=OFF"
      "-DHIGH_BIT_DEPTH=ON"
      "-DLINKED_8BIT=OFF"
      "-DLINKED_10BIT=OFF"
      "-DLINKED_12BIT=OFF"
      "-DMAIN12=OFF"
    ] ++ cmakeFlagsAll;

    preConfigure = /* x265 source directory is `source`, not `src` */ ''
      cd source
    '';

    nativeBuildInputs = [
      cmake
      ninja
      yasm
    ];

    buildInputs = optionals (elem targetSystem platforms.linux) [
      numactl
    ];

    postInstall =
      /* Remove unused files to prevent conflicts with
         pkg-config/libtool hooks */ ''
        rm -frv $out/includes
        rm -frv $out/lib/pkgconfig
      '' + /* Rename the library to a unique name */ ''
        mv -v $out/lib/libx265.a $out/lib/libx265_main10.a
      '';
  };
  libx265-12 = stdenv.mkDerivation {
    name = "libx265-12-${version}";

    inherit src;

    cmakeFlags = [
      "-DENABLE_CLI=OFF"
      "-DENABLE_SHARED=OFF"
      "-DEXPORT_C_API=OFF"
      "-DHIGH_BIT_DEPTH=ON"
      "-DLINKED_8BIT=OFF"
      "-DLINKED_10BIT=OFF"
      "-DLINKED_12BIT=OFF"
      "-DMAIN12=ON"
    ] ++ cmakeFlagsAll;

    preConfigure = /* x265 source directory is `source`, not `src` */ ''
      cd source
    '';

    nativeBuildInputs = [
      cmake
      ninja
      yasm
    ];

    buildInputs = optionals (elem targetSystem platforms.linux) [
      numactl
    ];

    postInstall =
      /* Remove unused files to prevent conflicts with
         pkg-config/libtool hooks */ ''
        rm -frv $out/includes
        rm -frv $out/lib/pkgconfig
      '' + /* Rename the library to a unique name */ ''
        mv -v $out/lib/libx265.a $out/lib/libx265_main12.a
      '';
  };
in

stdenv.mkDerivation rec {
  name = "x265-${version}";

  inherit src;

  nativeBuildInputs = [
    cmake
    ninja
    yasm
  ];

  buildInputs = [
    libx265-10
    libx265-12
  ] ++ optionals (elem targetSystem platforms.linux) [
    numactl
  ];

  postUnpack = /* x265 source directory is `source`, not `src` */ ''
    sourceRoot="$sourceRoot/source"
  '';

  postPatch = /* Work around to set version in the compiled binary */ ''
    sed -i cmake/version.cmake \
      -e 's/0.0/${version}/g'
  '';

  x265AdditionalLibs = [
    "${libx265-10}/lib/libx265_main10.a"
    "${libx265-12}/lib/libx265_main12.a"
  ];

  x265Libs = concatStringsSep ";" x265AdditionalLibs;

  cmakeFlags = [
    "-DDETAILED_CU_STATS=${boolOn custatsSupport}"
    "-DENABLE_CLI=${boolOn cliSupport}"
    "-DENABLE_SHARED=ON"
    "-DHIGH_BIT_DEPTH=OFF"
    "-DLINKED_8BIT=OFF"
    "-DLINKED_10BIT=ON"
    "-DLINKED_12BIT=ON"
    #"NO_ATOMICS"
    "-DSTATIC_LINK_CRT=OFF"
    "-DEXPORT_C_API=ON"
    "-DEXTRA_LIB=${x265Libs}"
  ] ++ cmakeFlagsAll;

  postInstall = /* Remove static library */ ''
    rm -v $out/lib/libx265.a
  '';

  meta = with stdenv.lib; {
    description = "Library for encoding h.265/HEVC video streams";
    homepage = http://x265.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, cmake
, fetchhg
#, fetchurl
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
    cmFlag
    concatStringsSep
    elem
    optionals
    platforms;
in

assert (elem targetSystem platforms.linux) -> numactl != null;

let
  version = "2.0";
  /*src = fetchurl {
    url = "https://bitbucket.org/multicoreware/x265/downloads/" +
          "x265_${version}.tar.gz";
    sha256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
  };*/
  #version = "2016-07-04";
  src = fetchhg {
    url = "https://bitbucket.org/multicoreware/x265";
    rev = "${version}";
    sha256 = "0a1gdxwzzwlgr76hg78v9hczf2lqq9l38k3dd6b29gxsprq2capd";
  };
  cmakeFlagsAll = [
    (cmFlag "ENABLE_TESTS" false)
    (cmFlag "ENABLE_AGGRESSIVE_CHECKS" false)
    (cmFlag "CHECKED_BUILD" debugSupport)
    (cmFlag "WARNINGS_AS_ERRORS" false)
    (cmFlag "ENABLE_PPA" false)
    (cmFlag "ENABLE_VTUNE" false)
    (cmFlag "ENABLE_PIC" true)
    (cmFlag "ENABLE_LIBNUMA" (
      (elem targetSystem platforms.linux)
      && numactl != null))
    (cmFlag "ENABLE_ASSEMBLY" true)
  ];
in

/* By default, the library and the encoder are configured for only
 * one output bit depth.  Meaning, one has to rebuild libx265 if
 * they want to produce HEVC files with a different bit depth,
 * which is annoying.  However, upstream supports proper namespacing
 * for 8bit, 10bit & 12bit HEVC and linking all that together so that
 * the resulting library can produce all three of them instead of
 * only one.  The API requires the bit depth parameter, so that
 * libx265 can then chose which variant of the encoder to use.  To
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
      (cmFlag "HIGH_BIT_DEPTH" true)
      (cmFlag "EXPORT_C_API" false)
      (cmFlag "ENABLE_SHARED" false)
      (cmFlag "ENABLE_CLI" false)
      (cmFlag "MAIN12" false)
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
      (cmFlag "HIGH_BIT_DEPTH" true)
      (cmFlag "EXPORT_C_API" false)
      (cmFlag "ENABLE_SHARED" false)
      (cmFlag "ENABLE_CLI" false)
      (cmFlag "MAIN12" true)
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
      -e 's/unknown/${version}/g'
  '';

  x265AdditionalLibs = [
    "${libx265-10}/lib/libx265_main10.a"
    "${libx265-12}/lib/libx265_main12.a"
  ];

  x265Libs = "${concatStringsSep ";" x265AdditionalLibs}";

  cmakeFlags = [
    (cmFlag "ENABLE_SHARED" true)
    (cmFlag "STATIC_LINK_CRT" false)
    (cmFlag "DETAILED_CU_STATS" custatsSupport)
    (cmFlag "ENABLE_CLI" cliSupport)
  ] ++ cmakeFlagsAll
    ++ [
    (cmFlag "EXTRA_LIB" "${x265Libs}")
    (cmFlag "LINKED_10BIT" true)
    (cmFlag "LINKED_12BIT" true)
  ];

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

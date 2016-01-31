{ stdenv
, cmake
, fetchurl
, ninja
, yasm

, numactl ? null

# Optionals
, cliSupport ? true # Build standalone CLI application
, unittestsSupport ? true # Unit tests
# Debugging options
, debugSupport ? false # Run-time sanity checks (debugging)
, werrorSupport ? false # Warnings as errors
, ppaSupport ? false # PPA profiling instrumentation
, vtuneSupport ? false # Vtune profiling instrumentation
, custatsSupport ? false # Internal profiling of encoder work
}:

with {
  inherit (stdenv)
    is64bit
    isLinux;
  inherit (stdenv.lib)
    cmFlag
    concatStringsSep
    optionals;
};

assert isLinux -> numactl != null;

let
  version = "1.9";
  src = fetchurl {
    url = "https://bitbucket.org/multicoreware/x265/downloads/" +
          "x265_${version}.tar.gz";
    sha256 = "1j0mbcf10aj6zi1nxql45f9817jd2ndcpd7x123sjmyr7q9m8iiy";
  };
  cmakeFlagsAll = [
    (cmFlag "ENABLE_TESTS" unittestsSupport)
    (cmFlag "CHECKED_BUILD" debugSupport)
    (cmFlag "WARNINGS_AS_ERRORS" werrorSupport)
    (cmFlag "ENABLE_PPA" ppaSupport)
    (cmFlag "ENABLE_VTUNE" vtuneSupport)
    (cmFlag "ENABLE_PIC" true)
    (cmFlag "ENABLE_LIBNUMA" (isLinux && numactl != null))
    (cmFlag "ENABLE_ASSEMBLY" true)
  ];
in

/* By default, the library and the encoder are configured for only
 * one output bit depth.  Meaning, one has to rebuild libx265 if
 * they wants to produce HEVC files with a different bit depth,
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

    preConfigure =
    /* x265 source directory is `source`, not `src` */ ''
      cd source
    '';

    nativeBuildInputs = [
      cmake
      ninja
      yasm
    ];

    buildInputs = optionals isLinux [
      numactl
    ];

    postInstall =
    /* Remove unused files to prevent conflicts with
       pkg-config/libtool hooks */ ''
      rm -rvf $out/includes
      rm -rvf $out/lib/pkgconfig
    '' +
    /* Rename the library to a unique name */ ''
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

    preConfigure =
    /* x265 source directory is `source`, not `src` */ ''
      cd source
    '';

    nativeBuildInputs = [
      cmake
      ninja
      yasm
    ];

    buildInputs = optionals isLinux [
      numactl
    ];

    postInstall =
    /* Remove unused files to prevent conflicts with
       pkg-config/libtool hooks */ ''
      rm -rvf $out/includes
      rm -rvf $out/lib/pkgconfig
    '' +
    /* Rename the library to a unique name */ ''
      mv -v $out/lib/libx265.a $out/lib/libx265_main12.a
    '';
  };
in

stdenv.mkDerivation rec {
  name = "x265-${version}";

  inherit src;

  postUnpack =
  /* x265 source directory is `source`, not `src` */ ''
    sourceRoot="$sourceRoot/source"
  '';

  patchPhase =
  /* Work around to set version in the compiled binary */ ''
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
    ++ optionals is64bit [
    (cmFlag "EXTRA_LIB" "${x265Libs}")
    (cmFlag "LINKED_10BIT" true)
    (cmFlag "LINKED_12BIT" true)
  ];

  postInstall =
  /* Remove static library */ ''
    rm -f $out/lib/libx265.a
  '';

  nativeBuildInputs = [
    cmake
    ninja
    yasm
  ];

  buildInputs = optionals is64bit [
    libx265-10
    libx265-12
  ] ++ optionals isLinux [
    numactl
  ];

  meta = with stdenv.lib; {
    description = "Library for encoding h.265/HEVC video streams";
    homepage = http://x265.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

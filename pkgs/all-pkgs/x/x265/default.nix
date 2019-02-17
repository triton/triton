{ stdenv
, cmake
, fetchFromBitbucket
, fetchurl
, lib
, nasm
, ninja

, numactl
, vmaf ? null  # TODO: VMAF support.

# Optionals
, cliSupport ? true # Build standalone CLI application
, custatsSupport ? false # Internal profiling of encoder work

, channel
}:

# NOTE: Tarballs hosted on bitbucket are non-deterministic.

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolOn
    concatStringsSep
    elem
    optionals
    platforms;

  sources = {
    "stable" = {
      version = "3.0";
      md5confirm = "8ff1780246bb7ac8506239f6129c04ec";
      multihash = "QmTRoGtatifcPPHjL22njyYSn381wb6wJsrrDzZXtVMjm7";
      sha256 = "c5b9fc260cabbc4a81561a448f4ce9cad7218272b4011feabc3a6b751b2f0662";
    };
    "head" = {
      fetchzipversion = 6;
      version = "2019-02-08";
      rev = "dcbec33bfb0f1cabdb1ff9eaadba5305ba23e6fa";
      sha256 = "cd7bfb8b68bf9a8b19ffe73ba8e70eedc3982c554318fd11e53fa943faccb8a6";
    };
  };
  source = sources."${channel}";

  src =
    if channel == "head" then
      fetchFromBitbucket {
        version = source.fetchzipversion;
        owner = "multicoreware";
        repo = "x265";
        inherit (source) rev sha256;
      }
    else
      fetchurl {
        urls = [
          ("https://bitbucket.org/multicoreware/x265/downloads/"
            + "x265_${source.version}.tar.gz")
          ("mirror://videolan/x265/x265_${source.version}.tar.gz")
        ];
        inherit (source) multihash sha256;
      };

  cmakeFlagsAll = [
    "-DENABLE_ASSEMBLY=ON"
    "-DENABLE_LIBNUMA=${boolOn (
      elem targetSystem platforms.linux
      && numactl != null)}"
    "-DENABLE_PIC=ON"
    "-DDETAILED_CU_STATS=${boolOn custatsSupport}"
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
    name = "libx265-10-${source.version}";

    inherit src;

    cmakeFlags = [
      "-DENABLE_CLI=OFF"
      "-DENABLE_SHARED=OFF"
      "-DENABLE_HDR10_PLUS=ON"
      "-DEXPORT_C_API=OFF"
      "-DHIGH_BIT_DEPTH=ON"
      "-DMAIN12=OFF"
    ] ++ cmakeFlagsAll;

    postUnpack = ''
      srcRoot="$srcRoot/source"
    '';

    postPatch = /* Work around to set version in the compiled binary */ ''
      sed -i cmake/version.cmake \
        -e '/X265_LATEST_TAG/s/0.0/${source.version}/g'
    '';

    nativeBuildInputs = [
      cmake
      nasm
      ninja
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
    name = "libx265-12-${source.version}";

    inherit src;

    cmakeFlags = [
      "-DENABLE_CLI=OFF"
      "-DENABLE_SHARED=OFF"
      "-DENABLE_HDR10_PLUS=ON"
      "-DEXPORT_C_API=OFF"
      "-DHIGH_BIT_DEPTH=ON"
      "-DMAIN12=ON"
    ] ++ cmakeFlagsAll;

    postUnpack = ''
      srcRoot="$srcRoot/source"
    '';

    postPatch = /* Work around to set version in the compiled binary */ ''
      sed -i cmake/version.cmake \
        -e '/X265_LATEST_TAG/s/0.0/${source.version}/g'
    '';

    nativeBuildInputs = [
      cmake
      nasm
      ninja
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
  name = "x265-${source.version}";

  inherit src;

  nativeBuildInputs = [
    cmake
    nasm
    ninja
  ];

  buildInputs = [
    libx265-10
    libx265-12
  ] ++ optionals (elem targetSystem platforms.linux) [
    numactl
  ];

  postUnpack = ''
    srcRoot="$srcRoot/source"
  '';

  postPatch = /* Work around to set version in the compiled binary */ ''
    sed -i cmake/version.cmake \
      -e '/X265_LATEST_TAG/s/0.0/${source.version}/g'
  '';

  x265AdditionalLibs = [
    "${libx265-10}/lib/libx265_main10.a"
    "${libx265-12}/lib/libx265_main12.a"
  ];

  x265Libs = concatStringsSep ";" x265AdditionalLibs;

  cmakeFlags = [
    "-DENABLE_CLI=${boolOn cliSupport}"
    "-DENABLE_SHARED=ON"
    "-DHIGH_BIT_DEPTH=OFF"
    "-DENABLE_HDR10_PLUS=OFF"
    "-DSTATIC_LINK_CRT=OFF"
    "-DEXPORT_C_API=ON"
    "-DEXTRA_LIB=${x265Libs}"
    "-DLINKED_10BIT=ON"
    "-DLINKED_12BIT=ON"
  ] ++ cmakeFlagsAll;

  postInstall = /* Remove static library */ ''
    rm -v $out/lib/libx265.a
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        md5Confirm = source.md5confirm;
      };
      failEarly = true;
    };
  };

  meta = with lib; {
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

{ stdenv
, cmake
, fetchTritonPatch
, fetchurl
, gcc
, ninja
, perl
, python3
, swig

, elfutils
, libedit
, libffi
, libxml2
, ncurses
, xz
, zlib

, channel
}:

let
  sources = import ./sources.nix;

  inherit (sources."${channel}")
    version
    patches
    srcs;

  inherit (stdenv.lib)
    flip
    makeOverridable
    mapAttrsToList;

  srcs' = flip mapAttrsToList srcs (n: d:
    let
      version' = d.version or version;
    in makeOverridable fetchurl {
      urls = [
        "https://github.com/llvm/llvm-project/releases/download/llvmorg-${version'}/${n}-${version'}.src.tar.xz"
        "https://releases.llvm.org/${version'}/${n}-${version'}.src.tar.xz"
        "https://distfiles.macports.org/llvm/${n}-${version'}.src.tar.xz"
      ];
      inherit (d)
        sha256;
    }
  );
in
stdenv.mkDerivation {
  name = "llvm-${version}";

  srcs = flip map srcs' (src: src.override {
    hashOutput = false;
  });

  srcRoot = "llvm-${version}.src";

  nativeBuildInputs = [
    cmake
    ninja
    perl
    python3
    swig
  ];

  buildInputs = [
    elfutils
    libedit
    libffi
    libxml2
    ncurses
    xz
    zlib
  ];

  prePatch = ''
    mkdir -p projects
    ls .. | grep '.src$' | grep -v '^llvm' \
      | sed 's,\(.*\)-[0-9]\+\.[0-9]\+\.[0-9]\+\(\|rc[0-9]\).src$,../\0 projects/\1,g' \
      | xargs -n 2 mv
    mv projects/clang tools/clang
    mv projects/clang-tools-extra tools/clang/tools/extra
    mv projects/lldb tools/lldb
  '';

  patches = map (d: d) patches;

  postPatch = ''
    # Remove impurities from llvm-config
    sed -i 's,@LLVM_.*_ROOT@,/no-such-path,g' tools/llvm-config/BuildVariables.inc.in

    # Remove impurities in polly
    sed -i "s,@POLLY_CONFIG_LLVM_CMAKE_DIR@,$out/lib/cmake/llvm," projects/polly/cmake/PollyConfig.cmake.in
  '';

  cmakeFlags = with stdenv; [
    "-DCMAKE_BUILD_TYPE=Release"

    "-DLLVM_INCLUDE_EXAMPLES=OFF"
    "-DLLVM_BUILD_TESTS=ON"
    "-DLLVM_ENABLE_RTTI=ON"
    "-DLLVM_INSTALL_UTILS=ON"  # Needed by rustc
    "-DLLVM_ENABLE_FFI=ON"

    # Not sure why these are needed
    "-DGCC_INSTALL_PREFIX=${gcc}"
    "-DC_INCLUDE_DIRS=${stdenv.cc.libc}/include"

    "-DLIBCXXABI_USE_LLVM_UNWINDER=ON"

    # TODO: Figure out how to make the single shared library work
    # for external builds
    "-DLLVM_BUILD_LLVM_DYLIB=ON"
    "-DLLVM_LINK_LLVM_DYLIB=ON"
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$(pwd)/tools/clang/include"
  '';

  preCheck = ''
    export LD_LIBRARY_PATH="''${LD_LIBRARY_PATH}''${LD_LIBRARY_PATH+:}$(pwd)/lib"
  '';

  passthru = {
    isClang = true;
    inherit gcc;

    srcsVerification = flip map srcs' (src: src.override {
      failEarly = true;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprints = [
          "11E5 21D6 4698 2372 EB57  7A1F 8F08 71F2 0211 9294"
          "B6C8 F982 82B9 44E3 B0D5  C253 0FC3 042E 345A D05D"
          "474E 2231 6ABF 4785 A88C  6E8E A2C7 94A9 8641 9D8A"
        ];
      };
    });
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

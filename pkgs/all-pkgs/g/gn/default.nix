{ stdenv
, fetchTritonPatch
, fetchurl
, lib
, ninja
, python2

, source-channel ? "stable"
}:

let
  # gn cannot be built out of the chromium source tree, so we use the
  # tarball for the chromium channel we are builing as a simpler way of
  # getting the necessary sources. Otherwise you would need chromium/src/base,
  # chromium/src/build, chromium/src/build/config, chromium/testing/gtest, &
  # chromium/src/third_patry/libevent.tar.gz in addition to
  # chromium/tools/gn.
  source = (import ../../c/chromium/sources.nix { })."${source-channel}";
in
stdenv.mkDerivation rec {
  name = "gn-${source.version}";

  src = fetchurl {
    url = "https://commondatastorage.googleapis.com/chromium-browser-official/"
      + "chromium-${source.version}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    ninja
    python2
  ];

  setupHook = ./setup-hook.sh;

  patches = [
    (fetchTritonPatch {
      rev = "81e065acf0b534fd119f6398d8ee8a941b740dc5";
      file = "c/chromium/chromium-gcc-r1.patch";
      sha256 = "8a2aee1382c0c689e9c5e34c9e392c7bdd01dafb98ef2ad623477bd8a339bc32";
    })
    (fetchTritonPatch {
      rev = "8d6e9728038c063e2441134bfca735c013b9bd6e";
      file = "c/chromium/chromium-gn-bootstrap-r14.patch";
      sha256 = "9df1913b936339782261f5302612e319f2a371ed15a9028c1049964697b5a21a";
    })
  ];

  postPatch = ''
    patchShebangs build/write_buildflag_header.py
    patchShebangs build/write_build_date_header.py
    patchShebangs tools/gn/bootstrap/bootstrap.py
  '';

  buildPhase = ''
    ./tools/gn/bootstrap/bootstrap.py --verbose --no-rebuild --no-clean
  '';

  installPhase = ''
    install -D -m755 -v 'out_bootstrap/gn' "$out/bin/gn"
  '';

  meta = with lib; {
    description = "Meta-build system that generates NinjaBuild files";
    homepage = https://chromium.googlesource.com/chromium/src/tools/gn;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

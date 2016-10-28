{ stdenv
, fetchurl
, lib
, ninja
, python2

, source-channel ? "stable"
}:

let
  # gn cannot be built out of the expected source tree, so we use the
  # dev tarball as a simpler way of getting the necessary sources,
  # while ensuring gn is up-to-date for all channels. Otherwise you
  # would need chromium/src/base, chromium/src/build,
  # chromium/src/build/config, chromium/testing/gtest, &
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

  postPatch = ''
    patchShebangs build/write_buildflag_header.py
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

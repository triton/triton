{ stdenv
, fetchFromGitHub
, fetchTritonPatch
, gnum4
, gperf
, meson
, ninja
, python3

, audit_lib
, libcap
, libgcrypt
, libgpg-error
, libidn2
, libselinux
, lz4
, util-linux_lib
, xz
}:

let
  # This is intentionally a separate version from the full build
  # in case we don't have any library changes
  version = "245.5";
in
stdenv.mkDerivation {
  name = "libsystemd-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "systemd";
    repo = "systemd-stable";
    rev = "v${version}";
    sha256 = "2694bbe2330b541bd559839513ecf660f5c1e38ea547aab94b706e1686205093";
  };

  nativeBuildInputs = [
    gnum4
    gperf
    meson
    ninja
    python3
  ];

  buildInputs = [
    audit_lib
    libcap
    libgcrypt
    libgpg-error
    libidn2
    libselinux
    lz4
    util-linux_lib
    xz
  ];

  patches = [
   (fetchTritonPatch {
      rev = "6194784552cf12b852931fd444cfba6f5bb4fac9";
      file = "s/systemd/0001-lib-hwdb-Add-triton-path.patch";
      sha256 = "10d076aaa90990d2f483135fbeab496ac803a8a6daff5f79f8a46580d7520e00";
    })
  ];

  postPatch = ''
    patchShebangs tools/generate-gperfs.py

    # Remove unused subdirs and everything after src/udev
    # which in this case happens to be src/network
    sed \
      -e '\#^subdir(.po#d' \
      -e '\#^subdir(.catalog#d' \
      -e '\#^subdir(.src/login#d' \
      -e '\#^subdir(.src/network#,$d' \
      -i meson.build

    # Remove udev binaries that aren't used, all use libudev_core
    sed -i '\#^libudev_core_includes#,$d' src/udev/meson.build
  '';

  mesonFlags = [
    "-Drootprefix=/run/current-system/sw"
  ];

  preInstall = ''
    export DESTDIR="$out"
  '';

  # We need to work around install locations with the root
  # prefix and dest dir
  postInstall = ''
    dir="$out$out"
    cp -ar "$dir"/* "$out"
    while [ "$dir" != "$out" ]; do
      rm -r "$dir"
      dir="$(dirname "$dir")"
    done
    cp -ar "$out"/run/current-system/sw/* "$out"
    rm -r "$out"/{etc,run,share,var}
  '';

  # Make sure we don't have superfluous libs
  preFixup = ''
    find "$out"/lib -mindepth 1 \( -type d -and -not -name pkgconfig \) -prune -exec rm -r {} \;
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

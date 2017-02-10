{ stdenv
, fetchTritonPatch
, fetchurl
, makeWrapper
, python
, scons
, which

, expat
, libavc1394
, libconfig
, libiec61883
, libraw1394

# Optional dependencies
, alsa-lib
, dbus
, jack2_lib
, xdg-utils

# Other Flags
, prefix ? ""
}:

let
  libOnly = prefix == "lib";

  inherit (stdenv)
    targetSystem;

  inherit (stdenv.lib)
    elem
    optionals
    optionalString
    platforms;

  version = "2.3.0";

  gcc-warnings_patch =
    (fetchTritonPatch {
      rev = "584cf8c80a7323ba45b31f5da22580e4f9493cf2";
      file = "f/ffado/gcc-warnings.patch";
      sha256 = "b10cb5edb06aec4a08e16134e493cab0d6e8c831e44afdfa95c6b901cc0a1ee0";
    });
in
stdenv.mkDerivation rec {
  name = "${prefix}ffado-${version}";

  src = fetchurl {
    url = "http://www.ffado.org/files/libffado-${version}.tgz";
    multihash = "Qmdhm6mWmGbguNFibZYhW2eQHYovjGGkQCydShQ8Af93yj";
    sha256 = "18e3c7e610b7cee58b837c921ebb985e324cb2171f8d130f79de02a3fc435f88";
  };

  nativeBuildInputs = [
    makeWrapper
    python
    scons
    which
  ];

  buildInputs = [
    expat
    libavc1394
    libconfig
    libiec61883
    libraw1394
  ] ++ optionals (!libOnly) [
    alsa-lib
    dbus
    jack2_lib
    xdg-utils
  ];

  patches = [
    (fetchTritonPatch {
      rev = "584cf8c80a7323ba45b31f5da22580e4f9493cf2";
      file = "f/ffado/cpuinfo-parsing.patch";
      sha256 = "5d4b20e177549a4b3e8a0a0d8eaffee9e39c1aa5810d3670dde729be12487989";
    })
    (fetchTritonPatch {
      rev = "584cf8c80a7323ba45b31f5da22580e4f9493cf2";
      file = "f/ffado/fix-build.patch";
      sha256 = "15fe33c2b1bb6bfb687df27816df4179feb56112f83afc8dfefb44915b5f848c";
    })
    (fetchTritonPatch {
      rev = "584cf8c80a7323ba45b31f5da22580e4f9493cf2";
      file = "f/ffado/gcc6.patch";
      sha256 = "2b4681a780ee6af1db56444edaa172d01df391d723ac946a25a1e774db59a77f";
    })
  ];

  postPatch = ''
    patch -Np3 -i "${gcc-warnings_patch}"

    # SConstruct checks cpuinfo and an objdump of /bin/mount to determine the appropriate arch
    # Let's just skip this and tell it which to build
    sed '/def is_userspace_32bit(cpuinfo):/a\
        return ${if (elem targetSystem platforms.bit64) then "False" else "True"}' -i SConstruct
  '';

  preBuild = ''
    buildFlagsArray+=("PYPKGDIR=$(toPythonPath "$out")")
  '';

  buildFlags = [
    "DEBUG=False"
    "ENABLE_ALL=True"
    "SERIALIZE_USE_EXPAT=True"
  ];

  preInstall = if libOnly then ''
    installFlagsArray+=(
      "PREFIX=$TMPDIR"
      "UDEVDIR=$TMPDIR"
      "LIBDIR=$out/lib"
      "INCLUDEDIR=$out/include"
      "SHAREDIR=$out/share"
    )
  '' else ''
    installFlagsArray+=(
      "PREFIX=$out"
      "PYPKGDIR=$(toPythonPath "$out")"
      "UDEVDIR=$out/lib/udev/rules.d"
    )
  '';

  postInstall = optionalString (!libOnly) ''
    wrapProgram $out/bin/ffado-mixer --prefix PYTHONPATH : \
      "$PYTHONPATH:$PYDIR"

    wrapProgram $out/bin/ffado-diag --prefix PYTHONPATH : \
      "$PYTHONPATH:$PYDIR:$out/share/libffado/python"
  '';

  meta = with stdenv.lib; {
    homepage = http://www.ffado.org;
    description = "FireWire audio drivers";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchTritonPatch
, fetchurl
, lib
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

  version = "2.4.0";

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
    multihash = "QmfDoK6vRALc6h8zHe62NqZDdJrzPLdSLBzRTRjiL4mCct";
    sha256 = "8e380032816e6fd93bd42dca8bf1828965d1befc1f4049677afb3ed018cd3793";
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

  postPatch = /* Missing sys import, fixed in next release */ ''
    sed -i SConstruct \
      -e '/import re/a import sys'
  '' + ''
    # SConstruct checks cpuinfo and an objdump of /bin/mount to determine the
    # appropriate arch.  Let's just skip this and tell it which to build.
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

  meta = with lib; {
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

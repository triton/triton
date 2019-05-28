{ stdenv
, cmake
, lib
}:

let
  inherit (cmake)
    channel
    version;
in
stdenv.mkDerivation rec {
  name = "cmake-bootstrap-${version}";

  inherit (cmake)
    src
    patches;

  postPatch = /* LibUV 1.21.0+ compat */ ''
    ! grep -q 'uv/version.h' Source/Modules/FindLibUV.cmake
    sed -i 's,uv-version.h,uv/version.h,' Source/Modules/FindLibUV.cmake

    sed \
      -e 's,''${cmake_bootstrap_dir}/cmake,true,' \
      -e "/\''${CMAKE_BOOTSTRAP_SOURCE_DIR}/iCMAKE_BOOTSTRAP_SOURCE_DIR='$out/share/cmake-${channel}'" \
      -e "/\''${CMAKE_BOOTSTRAP_BINARY_DIR}/iCMAKE_BOOTSTRAP_BINARY_DIR='$out/bin'" \
      -i bootstrap
  '';

  preConfigure = ''
    fixCmakeFiles Modules Templates

    configureFlagsArray+=("--parallel=$NIX_BUILD_CORES")
  '';

  buildPhase = ''
    true
  '';

  installPhase = ''
    mkdir -p "$out"/bin
    cp Bootstrap.cmk/cmake "$out"/bin
    mkdir -p "$out"/share/cmake-${channel}
    cp -r Modules Templates "$out"/share/cmake-${channel}
  '';

  setupHook = ./setup-hook.sh;
  selfApplySetupHook = true;
  cmakeHook = false;

  meta = with lib; {
    description = "Cross-Platform Makefile Generator";
    homepage = http://www.cmake.org/;
    license = licenses.free; # cmake
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

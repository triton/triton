{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "dpdk-17.05";

  src = fetchurl {
    url = "http://fast.dpdk.org/rel/${name}.tar.xz";
    multihash = "QmbkSWfvN9jdH2vpr34Hpvqk2fgMrPWB6R1q5giYhaYwXN";
    sha256 = "c8503392bcc2f1eac236034ea0f3aed1c3c6a23327ec3c81937fc1068a44b78f";
  };

  # We want to make sure we always target nehalem for all builds
  preConfigure = ''
    sed -i 's,\(CONFIG_RTE_MACHINE\).*,\1="nhm",g' config/defconfig_x86_64-native-linuxapp-gcc
    makeFlagsArray+=(RTE_KERNELDIR=.)
  '';

  configurePhase = ''
    runHook preConfigure
    make config -j $NIX_BUILD_CORES T=x86_64-native-linuxapp-gcc
    runHook postConfigure
  '';

  makefile = "GNUmakefile";

  meta = with lib; {
    description = "Libraries and drivers for fast packet processing";
    homepage = http://dpdk.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

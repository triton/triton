{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "dpdk-16.04";

  src = fetchurl {
    url = "http://fast.dpdk.org/rel/${name}.tar.xz";
    multihash = "QmNa4P2aH5qNajc72LJbh9LdtSBPxuaYWq6wKDRiwsSoDP";
    sha256 = "1fwqljvg0lr94qlba2xzn3zqg1jcbj4yz450k72fgj4mqpjsdmys";
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

  meta = with stdenv.lib; {
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

{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "dpdk-2.2.0";

  src = fetchurl {
    url = "http://dpdk.org/browse/dpdk/snapshot/${name}.tar.gz";
    sha256 = "03b1pliyx5psy3mkys8j1mk6y2x818j6wmjrdvpr7v0q6vcnl83p";
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
    license = licenses.bsd3;
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
    maintainers = with maintainers; [
      wkennington
    ];
  };
}

{ stdenv, fetchurl, openssl, iptables }:

assert stdenv.isLinux;

stdenv.mkDerivation rec {
  name = "miniupnpd-1.9.20160209";

  src = fetchurl {
    name = "${name}.tar.gz";
    url = "http://miniupnp.free.fr/files/download.php?file=${name}.tar.gz";
    sha256 = "0r4giqsr39s17mn9lmmy3zawrfj7kj9im7nzv7mx3rgz2ncw092z";
  };

  buildInputs = [ openssl ]
    ++ (if stdenv.isLinux then [ iptables ] else [ ]);

  # The upstream build is missing some of its test scripts
  # Therefore we add dummy ones allowing it to pass
  postPatch = ''
    fake_script() {
      echo "#!/bin/sh" > $1
      chmod +x $1
    }
    fake_script testupnppermissions.sh
    fake_script testgetifaddr.sh
  '';

  configureScript = "./genconfig.sh";

  dontAddPrefix = true;

  preConfigure = ''
    configureFlagsArray+=("--ipv6")
    configureFlagsArray+=("--igd2")
    configureFlagsArray+=("--leasefile")
    configureFlagsArray+=("--pcp-peer")
  '';

  postConfigure = ''
    sed -i 's,.*\(#define USE_MINIUPNPDCTL\).*,\1,g' config.h
  '';

  doCheck = true;

  makefile = if stdenv.isLinux then "Makefile.linux" else "Makefile";

  makeFlags = [ "all" ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  preInstall = ''
    installFlagsArray+=("INSTALLPREFIX=$out")
  '';

  postInstall = ''
    mkdir -p $out/bin
    install miniupnpdctl $out/bin
  '';

  meta = with stdenv.lib; {
    homepage = http://miniupnp.free.fr/;
    description = "A daemon that implements the UPnP Internet Gateway Device (IGD) specification";
    platforms = platforms.linux;
  };
}

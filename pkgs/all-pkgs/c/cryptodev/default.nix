{ stdenv
, fetchurl

, kernel

, onlyHeaders ? false
}:

let
  inherit (stdenv.lib)
    optionalString;
in
stdenv.mkDerivation rec {
  name = "cryptodev-linux-1.8";

  src = fetchurl {
    url = "http://download.gna.org/cryptodev-linux/${name}.tar.gz";
    multihash = "QmQFLhYrHeLWqEzXd1EvCwm1Af9KXwWmXDunAWgTwPW4pa";
    hashOutput = false;
    sha256 = "0xhkhcdlds9aiz0hams93dv0zkgcn2abaiagdjlqdck7zglvvyk7";
  };

  # If we are only building headers, just do that
  buildCommand = optionalString onlyHeaders ''
    unpackPhase
    mkdir -p $out/include/crypto
    cp */crypto/cryptodev.h $out/include/crypto
  '';

  preBuild = optionalString (!onlyHeaders) ''
    makeFlagsArray+=(
      "-C" "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "SUBDIRS=$(pwd)"
      "INSTALL_PATH=$out"
    )
    installFlagsArray+=("INSTALL_MOD_PATH=$out")
  '';

  installTargets = [
    "modules_install"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Device that allows access to Linux kernel cryptographic drivers";
    homepage = http://home.gna.org/cryptodev-linux/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

{ stdenv
, fetchurl

, kernel

, onlyHeaders ? false
}:

let
  inherit (stdenv.lib)
    optionalString;

  tarballUrls = version: [
    "http://nwl.cc/pub/cryptodev-linux/cryptodev-linux-${version}.tar.gz"
    "http://download.gna.org/cryptodev-linux/cryptodev-linux-${version}.tar.gz"
  ];

  version = "1.9";
in
stdenv.mkDerivation rec {
  name = "cryptodev-linux-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmZqPXZDUZdsjnkx7wbYUirnzj6ajmGTA1DzMXe9gtXU2a";
    hashOutput = false;
    sha256 = "9f4c0b49b30e267d776f79455d09c70cc9c12c86eee400a0d0a0cd1d8e467950";
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
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.9";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "EE81 2532 E317 608B 671D  9760 DA30 48E2 7A12 7A6F";
      inherit (src) outputHashAlgo;
      outputHash = "9f4c0b49b30e267d776f79455d09c70cc9c12c86eee400a0d0a0cd1d8e467950";
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

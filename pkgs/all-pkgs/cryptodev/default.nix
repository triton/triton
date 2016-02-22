{ stdenv
, fetchurl

, kernel

, onlyHeaders ? false
}:

let
  inherit (stdenv.lib) optionalString;
in
stdenv.mkDerivation rec {
  name = "cryptodev-linux-1.8";

  src = fetchurl {
    url = "http://download.gna.org/cryptodev-linux/${name}.tar.gz";
    sha256 = "0xhkhcdlds9aiz0hams93dv0zkgcn2abaiagdjlqdck7zglvvyk7";
  };

  # If we are only building headers, just do that
  buildCommand = optionalString onlyHeaders ''
    mkdir -p $out/include/crypto
    cp crypto/cryptodev.h $out/include/crypto
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

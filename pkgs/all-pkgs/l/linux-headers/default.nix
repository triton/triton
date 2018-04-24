{ stdenv
, fetchurl
, channel
}:

let
  sources = {
    "4.4" = {
      major = "4";
      version = "4.4.57";
      sha256 = "92ff2916fe6401006e4d96f83fcd3d55f45c741f0a95efeff1b2a259ef59b2ca";
    };
    "4.9" = {
      major = "4";
      version = "4.9";
      sha256 = "029098dcffab74875e086ae970e3828456838da6e0ba22ce3f64ef764f3d7f1a";
    };
    "4.14" = {
      major = "4";
      version = "4.14";
      sha256 = "f81d59477e90a130857ce18dc02f4fbe5725854911db1e7ba770c7cd350f96a7";
    };
  };

  source = sources."${channel}";

  tarballUrls = [
    "mirror://kernel/linux/kernel/v${source.major}.x/linux-${source.version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "linux-headers-${source.version}";
  version = source.version;

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    inherit (source) sha256;
  };

  buildFlags = [
    "defconfig"
  ];

  preInstall = ''
    installFlagsArray+=("INSTALL_HDR_PATH=$out")
  '';

  installTargets = "headers_install";

  preFixup = ''
    # Cleanup some unneeded files
    find $out/include \( -name .install -o -name ..install.cmd \) -delete
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}.sign") tarballUrls;
      pgpKeyFingerprints = [
        "647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E"
        "ABAF 11C6 5A29 70B1 30AB  E3C4 79BE 3E43 0041 1886"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Header files and scripts for Linux kernel";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

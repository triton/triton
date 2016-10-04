{ stdenv
, fetchurl
, channel
}:

let
  sources = {
    "3.18" = {
      major = "3";
      version = "3.18.14";
      sha256 = "1xh0vvn1l2g1kkg54f0mg0inbpsiqs24ybgsakksmcpcadjgqk1i";
    };
    "4.6" = {
      major = "4";
      version = "4.6";
      sha256 = "a93771cd5a8ad27798f22e9240538dfea48d3a2bf2a6a6ab415de3f02d25d866";
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
      pgpKeyFingerprint = "647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E";
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

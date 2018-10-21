{ stdenv
, fetchurl
, lib

, channel
}:

let
  sources = {
    "4.9" = {
      version = "4.9.135";
      baseSha256 = "029098dcffab74875e086ae970e3828456838da6e0ba22ce3f64ef764f3d7f1a";
      patchSha256 = "daa1463233ece4eaad4c43a98bc54f165ae598927128ca63715f12d9e43772eb";
    };
    "4.14" = {
      version = "4.14.78";
      baseSha256 = "f81d59477e90a130857ce18dc02f4fbe5725854911db1e7ba770c7cd350f96a7";
      patchSha256 = "d491f69f4075e514c5f2e8d520980a96066b6f5e087decff23c79a799ac199a2";
    };
  };

  source = sources."${channel}";

  sourceFetch = import ../linux/source.nix {
    inherit
      lib
      fetchurl
      source;
    fetchFromGitHub = null;
  };

  headerArch = {
    "x86_64-linux" = "x86_64";
    "i686-linux" = "i386";
  };
in
stdenv.mkDerivation rec {
  name = "linux-headers-${source.version}";

  inherit (sourceFetch)
    src;

  patches = [
    sourceFetch.patch
  ];

  # The header install process requires a configuration
  # The default configuration should be suitable for this
  buildFlags = [
    "defconfig"
  ];

  preInstall = ''
    installFlagsArray+=("INSTALL_HDR_PATH=$out")
  '';

  installFlags = [
    "ARCH=${headerArch."${stdenv.targetSystem}"}"
  ];

  installTargets = "headers_install";

  preFixup = ''
    # Cleanup some unneeded files
    find "$out"/include \( -name .install -o -name ..install.cmd \) -delete
  '';

  # The linux-headers do not need to maintain any references
  allowedReferences = [ ];

  passthru = {
    inherit channel;
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

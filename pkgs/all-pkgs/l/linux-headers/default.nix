{ stdenv
, bison
, fetchurl
, flex
, lib

, channel
}:

let
  sources = {
    "4.14" = {
      version = "4.14.114";
      baseSha256 = "f81d59477e90a130857ce18dc02f4fbe5725854911db1e7ba770c7cd350f96a7";
      patchSha256 = "e1375e916f202b5ce73e17aa673aea741d2995f10eb448bb0581e3f82c8efe19";
    };
    "4.19" = {
      version = "4.19.37";
      baseSha256 = "0c68f5655528aed4f99dae71a5b259edc93239fa899e2df79c055275c21749a1";
      patchSha256 = "517d79fc64b4c95ee5845ce21e4c60efb8f9479ce7c4ca2ac3496cf670e906ff";
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

  inherit (lib)
    optionals
    versionAtLeast;
in
stdenv.mkDerivation rec {
  name = "linux-headers-${source.version}";

  inherit (sourceFetch)
    src;

  nativeBuildInputs = optionals (versionAtLeast source.version "4.16") [
    bison
    flex
  ];

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

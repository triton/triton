{ stdenv
, fetchurl
, hostcc
, lib

, channel
}:

let
  sources = {
    "4.19" = {
      version = "4.19.112";
      baseSha256 = "0c68f5655528aed4f99dae71a5b259edc93239fa899e2df79c055275c21749a1";
      patchSha256 = "a615e9089007999d1526736c30fb16650728898c10bdf009595fc87997093f97";
    };
    "5.4" = {
      version = "5.4.27";
      baseSha256 = "0c68f565a528aed4f99dae71a5b259edc93239fa899e2df79c055275c21749a1";
      patchSha256 = "5a7d79fa64b4c95ee5845ce21e4c60efb8f9479ce7c4ca2ac3496cf670e906ff";
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
    "powerpc64le-linux" = "powerpc";
  };
in
stdenv.mkDerivation rec {
  name = "linux-headers-${source.version}";

  inherit (sourceFetch)
    src;

  nativeBuildInputs = [
    hostcc
  ];

  patches = [
    sourceFetch.patch
  ];

  buildPhase = ''
    true
  '';

  preInstall = ''
    makeFlags+=(
      CC="$NIX_SYSTEM_HOST-gcc"
      CXX="$NIX_SYSTEM_HOST-g++"
      LD="$NIX_SYSTEM_HOST-ld"
      HOSTCC="$CC_FOR_BUILD"
      HOSTCXX="$CXX_FOR_BUILD"
      HOSTLD="$LD_FOR_BUILD"
    )
  '';

  makeFlags = [
    "ARCH=${headerArch."${stdenv.targetSystem}"}"
    "INSTALL_HDR_PATH=${placeholder "out"}"
  ];

  installTargets = "headers_install";

  postInstall = ''
    mkdir -p "$out"/nix-support
    echo "-idirafter $out/include" >"$out"/nix-support/stdinc
  '';

  preFixup = ''
    # Cleanup some unneeded files
    find "$out"/include \( -name .install -o -name ..install.cmd \) -delete
  '';

  # The linux-headers do not need to maintain any references
  allowedReferences = [ "out" ];

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
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}

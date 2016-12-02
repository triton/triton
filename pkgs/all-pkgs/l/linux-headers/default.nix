{ stdenv
, fetchurl
, lib

, channel
}:

let
  sources = {
    "4.9" = {
      version = "4.9.65";
      baseSha256 = "029098dcffab74875e086ae970e3828456838da6e0ba22ce3f64ef764f3d7f1a";
      patchSha256 = "3e1937ad3aeb89ac247e96551059babe3c959c6c8868107adac6f3634e39a4ae";
    };
    "4.14" = {
      version = "4.14.2";
      baseSha256 = "f81d59477e90a130857ce18dc02f4fbe5725854911db1e7ba770c7cd350f96a7";
      patchSha256 = "2dc86272e55d31c55bdeaa47b3d44fbd6235a396e37d82c2b47aa27f6ba82ee3";
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
    "i686-linux" = "i686";
  };
in
stdenv.mkDerivation rec {
  name = "linux-headers-${source.version}";

  inherit (sourceFetch)
    src;

  patches = [
    sourceFetch.patch
  ];

  # There is no build process. Work is done entirely done by headers_install
  buildPhase = ''
    true
  '';

  preInstall = ''
    installFlagsArray+=("INSTALL_HDR_PATH=$out")
  '';

  installFlags = [
    "ARCH=${headerArch."${stdenv.targetSystem}"}"
  ];

  installTargets = "headers_install";

  preFixup = ''
    # Cleanup some unneeded files
    find $out/include \( -name .install -o -name ..install.cmd \) -delete
  '';

  # We don't need to fix the flags as this build comes early and
  # binaries are only used for supporting the build process
  ccFixFlags = false;

  # The linux-headers do not need to maintain any references
  allowedReferences = [ ];

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

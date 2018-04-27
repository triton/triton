{ stdenv
, cc
, fetchurl
, lib
, gnumake
, gnupatch
, gnutar
, xz

, channel
}:

let
  sources = {
    "4.9" = {
      version = "4.9.96";
      baseSha256 = "029098dcffab74875e086ae970e3828456838da6e0ba22ce3f64ef764f3d7f1a";
      patchSha256 = "e04f5c59dffed0c6a8a81b89ecc82e3edbc6a03a97959039daaf42279a403a6c";
    };
    "4.14" = {
      version = "4.14.37";
      baseSha256 = "f81d59477e90a130857ce18dc02f4fbe5725854911db1e7ba770c7cd350f96a7";
      patchSha256 = "a74710e7cce987488dc43754c8f4f46cf99dd7870c28490f5b1ce322543950bd";
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

  nativeBuildInputs = [
    cc
    gnumake
    gnupatch
    gnutar
    xz
  ];

  patches = [
    sourceFetch.patch
  ];

  # There is no build process. Work is done entirely done by headers_install
  buildAction = ''
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

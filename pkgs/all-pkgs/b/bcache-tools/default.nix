{ stdenv
, fetchFromGitHub

, attr
, keyutils
, libnih
, libscrypt
, libsodium
, liburcu
, util-linux_lib
, zlib

, channel ? "stable"
}:

let
  sources = {
    "stable" = {
      fetchzipVersion = 2;
      version = "1.0.8";
      rev = "03bc5a32e5c14b75fb757902754480b8bcc3069e";
      sha256 = "339e97128db8a70c8da4cd51584634dda49d569314a0078361d075bf023580e6";
    };
    "dev" = {
      fetchzipVersion = 2;
      version = "2017-03-13";
      rev = "d252e12accd8b4fdc0e50b539370b203f3894de9";
      sha256 = "96d105c3f25e6f99fc5c8b61355d3f21dcd757fb21047d2e225ed1d92ad61036";
    };
  };

  inherit (stdenv.lib)
    optionals
    optionalString;

  inherit (sources.${channel})
    fetchzipVersion
    rev
    sha256
    version;
in
stdenv.mkDerivation {
  name = "bcache-tools-${version}";

  src = fetchFromGitHub {
    version = fetchzipVersion;
    owner = "wkennington";
    repo = "bcache-tools";
    inherit rev sha256;
  };

  buildInputs = [
    libnih
    util-linux_lib
  ] ++ optionals (channel == "dev") [
    attr
    keyutils
    libscrypt
    libsodium
    liburcu
    zlib
  ];

  postPatch = ''
    sed -i 's,<blkid.h>,<blkid/blkid.h>,g' tools-util.c
    sed -i 's,</usr/include/dirent.h>,<${stdenv.libc}/include/dirent.h>,g' cmd_migrate.c

    sed -i '/-static/d' Makefile
  '';

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "UDEVLIBDIR=$out/lib/udev"
    )
  '';

  preInstall = optionalString (channel == "stable") ''
    mkdir -p "$out/bin"
    mkdir -p "$out/sbin"
    mkdir -p "$out/share/man/man8"
    mkdir -p "$out/lib/udev/rules.d"
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

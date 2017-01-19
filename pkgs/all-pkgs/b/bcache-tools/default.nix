{ stdenv
, fetchFromGitHub

, keyutils
, libnih
, libscrypt
, libsodium
, liburcu
, util-linux_lib

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
      version = "2017-01-19";
      rev = "7e714d245b03aa64d052e3fe2ae7619792eeb91f";
      sha256 = "911e4461964f5021059bb75bc831668075358d7865ef784a4ddf6abfd439c1e6";
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
    keyutils
    libscrypt
    libsodium
    liburcu
  ];

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "UDEVLIBDIR=$out/lib/udev"
    )
    sed -i '/-static/d' Makefile
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

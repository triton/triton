{ stdenv
, fetchFromGitHub

, keyutils
, libnih
, libscrypt
, libsodium
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
      version = "2016-10-11";
      rev = "4e158e155327d09868453ae9759a58284245175a";
      sha256 = "3bc6ec9e498bdad2a6335ab6853d6e36e572739a7f3d32e4166830e08322ab14";
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

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
      version = "1.0.8";
      rev = "03bc5a32e5c14b75fb757902754480b8bcc3069e";
      sha256 = "339e97128db8a70c8da4cd51584634dda49d569314a0078361d075bf023580e6";
    };
    "dev" = {
      version = "2016-09-05";
      rev = "837a476cc139167fc483016f0a2635a048f7709e";
      sha256 = "da105b85089621bdb8b69236538d1e5d6d3ea221b19a9cb727264da4f5ae2325";
    };
  };

  inherit (stdenv.lib)
    optionals
    optionalString;

  inherit (sources.${channel})
    rev
    sha256
    version;
in
stdenv.mkDerivation {
  name = "bcache-tools-${version}";

  src = fetchFromGitHub {
    version = 2;
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

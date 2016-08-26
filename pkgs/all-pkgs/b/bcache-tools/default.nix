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
      sha256 = "496ae8691eb9c5a233bd99ed7984cbe129d702c322dc540143cd4012b24a4dad";
    };
    "dev" = {
      version = "2016-08-25";
      rev = "97de91cb580a2e31352860dfc0642579d21d3b7a";
      sha256 = "0f42bcd2f3226ad6e1bb0d3f8948a149467dcfa6e37d12c0421656159cb4d51c";
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

  preInstall = ''
    mkdir -p "$out/bin"
    mkdir -p "$out/sbin"
    mkdir -p "$out/share/man/man8"
  '' + optionalString (channel == "stable") ''
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

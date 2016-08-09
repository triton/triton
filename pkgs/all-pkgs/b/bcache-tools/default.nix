{ stdenv
, fetchFromGitHub

, libnih
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
      version = "2016-01-15";
      rev = "006a6a003d9529d50ecee205340b7a109bde4d76";
      sha256 = "f23a4209e196fa0483bd82804aec8e21b368492746d61b3235b46c44f8c654d0";
    };
  };

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
  ];

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "UDEVLIBDIR=$out/lib/udev"
    )
  '';

  preInstall = ''
    mkdir -p "$out/lib/udev/rules.d"
    mkdir -p "$out/bin"
    mkdir -p "$out/sbin"
    mkdir -p "$out/share/man/man8"
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

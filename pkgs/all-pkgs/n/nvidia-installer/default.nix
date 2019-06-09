{ stdenv
, fetchFromGitHub
, lib

, libpciaccess
, ncurses
, opengl-dummy
}:

let
  version = "430.14";
in
stdenv.mkDerivation rec {
  name = "nvidia-installer-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "NVIDIA";
    repo = "nvidia-installer";
    rev = "${version}";
    sha256 = "1ef62df2a511a2ebb4fb154d566739d72b65e2caf4ed6c0bf59f2e9e5335cbd7";
  };

  buildInputs = [
    libpciaccess
    ncurses
    opengl-dummy
  ];

  postPatch = ''
    # Remove check for Root user, builders are unprivledged.
    sed -i nvidia-installer.c \
      -e '/check_euid(op)/d'
  '';

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with lib; {
    description = "NVIDIA driver installer";
    homepage = https://github.com/NVIDIA/nvidia-installer;
    license = licenses.gpl2;
    maintainers = [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}


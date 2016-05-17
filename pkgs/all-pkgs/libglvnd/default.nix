{ stdenv
, autoreconfHook
, fetchFromGitHub
, perl
, python2

, xorg
}:

stdenv.mkDerivation rec {
  name = "libglvnd-${version}";
  version = "2016-05-11";

  src = fetchFromGitHub {
    owner = "nvidia";
    repo = "libglvnd";
    rev = "509de0dbc8b6be93dd9dc2e1b1b7b9268d4ddbdf";
    sha256 = "13dd4e8bbad9e4fd64da22ea3a4b7f7e83b41c1a0620defe5a9f9fdbe8f4ef74";
  };

  nativeBuildInputs = [
    autoreconfHook
    perl
    python2
  ];

  buildInputs = [
    xorg.glproto
    xorg.libX11
    xorg.libXext
    xorg.xorgserver
    xorg.xproto
  ];

  postPatch = ''
    patchShebangs ./src/generate
  '';

  meta = with stdenv.lib; {
    description = "The GL Vendor-Neutral Dispatch library";
    homepage = https://github.com/NVIDIA/libglvnd;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

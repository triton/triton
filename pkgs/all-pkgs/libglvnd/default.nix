{ stdenv
, autoreconfHook
, fetchFromGitHub
, perl
, python2

, xorg
}:

stdenv.mkDerivation rec {
  name = "libglvnd-${version}";
  version = "2016-06-09";

  src = fetchFromGitHub {
    owner = "nvidia";
    repo = "libglvnd";
    rev = "093f0485da8f4e9d39949b8a4ee20fd318b318ad";
    sha256 = "d143e7b617bdbd0f5f240b01f61a4713a16e386ba5509649f5a51c7f6521860a";
  };

  nativeBuildInputs = [
    autoreconfHook
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

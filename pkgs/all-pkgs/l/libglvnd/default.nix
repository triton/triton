{ stdenv
, autoreconfHook
, fetchFromGitHub
, perl
, python2

, xorg
}:

stdenv.mkDerivation rec {
  name = "libglvnd-2016-11-09";

  src = fetchFromGitHub {
    version = 2;
    owner = "NVIDIA";
    repo = "libglvnd";
    rev = "839a33ef435975a1c860fbdd16f5fc49f1fd3d8f";
    sha256 = "3f3fda7e42659a040fdd95c1f1559d331633ae8ccf35c8f40937f5f2d4e11d02";
  };

  nativeBuildInputs = [
    autoreconfHook
    python2
  ];

  buildInputs = [
    xorg.glproto
    xorg.libX11
    xorg.libXext
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
      x86_64-linux;
  };
}

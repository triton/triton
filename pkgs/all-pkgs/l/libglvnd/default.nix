{ stdenv
, autoreconfHook
, fetchFromGitHub
, perl
, python2

, xorg
}:

stdenv.mkDerivation rec {
  name = "libglvnd-2016-12-22";

  src = fetchFromGitHub {
    version = 2;
    owner = "NVIDIA";
    repo = "libglvnd";
    rev = "dc16f8c337703ad141f83583a4004fcf42e07766";
    sha256 = "1a0b8a6b1cad6803060993d70f1f12f76f26a09c3578c58642a9de029cdd6736";
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

  configureFlags = [
    "--enable-egl"
    "--enable-glx"
    "--enable-gles"
    "--enable-asm"
    "--enable-tls"
  ];

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

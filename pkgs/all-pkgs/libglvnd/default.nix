{ stdenv
, autoreconfHook
, fetchFromGitHub
, perl
, python2

, xorg
}:

stdenv.mkDerivation rec {
  name = "libglvnd-${version}";
  version = "2016-05-05";

  src = fetchFromGitHub {
    owner = "nvidia";
    repo = "libglvnd";
    rev = "5a69af6f77dd68fed4d54137c155676478dcccc3";
    sha256 = "7ce43319f086c5e15a95c4306aca933a4de0ca031fa4b3e6eeb30a1d479c0fca";
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
    patchShebangs ./src/GLX/gen_stubs.pl
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

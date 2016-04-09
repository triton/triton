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
    sha256 = "d9fab4260140b36b26e79dba47ff8739536dcad564c1be1ecf95c12177f7d2b2";
  };

  nativeBuildInputs = [
    autoreconfHook
    perl
    python2
  ];

  buildInputs = [
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

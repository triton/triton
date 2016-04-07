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
    sha256 = "b447645fb86d03268c8bed31e6fa1ad673c3e32f1d70e743cd616d70c1ae6326";
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

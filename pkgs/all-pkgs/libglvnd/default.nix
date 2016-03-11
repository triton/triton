{ stdenv
, autoreconfHook
, fetchFromGitHub
, perl
, python2

, xorg
}:

stdenv.mkDerivation rec {
  name = "libglvnd-${version}";
  version = "2016-02-26";

  src = fetchFromGitHub {
    owner = "nvidia";
    repo = "libglvnd";
    rev = "642fd89560312200a236dcc59dbe7d7f5d7e60ec";
    sha256 = "0lvhyix03zz44qqmb09y36j5k26jsynbpgfdqsxfa3b4n9cwaq2p";
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
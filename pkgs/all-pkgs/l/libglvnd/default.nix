{ stdenv
, autoreconfHook
, fetchFromGitHub
, perl
, python2

, xorg
}:

stdenv.mkDerivation rec {
  name = "libglvnd-2016-10-27";

  src = fetchFromGitHub {
    version = 1;
    owner = "NVIDIA";
    repo = "libglvnd";
    rev = "470fc824a38521a52707c6c0f59d827aa5e0f45a";
    sha256 = "28f713c7b075d3dc7bd6029afb171c5b416dab29aef7779d83b7620f4de8502f";
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

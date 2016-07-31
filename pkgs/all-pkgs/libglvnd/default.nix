{ stdenv
, autoreconfHook
, fetchFromGitHub
, perl
, python2

, xorg
}:

let
  version = "2016-07-13";
in
stdenv.mkDerivation rec {
  name = "libglvnd-${version}";

  src = fetchFromGitHub {
    owner = "nvidia";
    repo = "libglvnd";
    rev = "bb63d820dfd1ba4503ee849643ac1c24d90b9a90";
    sha256 = "bb489b730b3d685b664663499e40d75c1e964db526014c95624705558f6f5b58";
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

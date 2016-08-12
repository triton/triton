{ stdenv
, autoreconfHook
, fetchzip
, perl
, python2

, xorg
}:

let
  version = "0.1.1";
in
stdenv.mkDerivation rec {
  name = "libglvnd-${version}";

  src = fetchzip {
    url = "https://github.com/NVIDIA/libglvnd/archive/v${version}.tar.gz";
    sha256 = "a303021878625568e09712245d3b121788fa4c3ce246b449058ffae55ad40135";
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

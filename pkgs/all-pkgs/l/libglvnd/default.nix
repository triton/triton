{ stdenv
, autoreconfHook
, fetchFromGitHub
, perl
, python2

, xorg
}:

stdenv.mkDerivation rec {
  name = "libglvnd-2016-12-13";

  src = fetchFromGitHub {
    version = 2;
    owner = "NVIDIA";
    repo = "libglvnd";
    rev = "480046fa044343749c0ed2782bbccaefa66c1958";
    sha256 = "430b3c485564e0328856515152d9a0d2f8dea62958e544abb33084a0a1136810";
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

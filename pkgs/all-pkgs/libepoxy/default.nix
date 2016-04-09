{ stdenv
, autoreconfHook
, fetchFromGitHub
, python

, mesa
, xorg
}:

stdenv.mkDerivation rec {
  name = "libepoxy-${version}";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "anholt";
    repo = "libepoxy";
    rev = "v${version}";
    sha256 = "a236cdfe2293d545fafc51e5ba5f7fcb8f41deea0f897875c873034f2c4f4bb1";
  };

  nativeBuildInputs = [
    autoreconfHook
    python
    xorg.utilmacros
  ];

  buildInputs = [
    mesa
    xorg.libX11
  ];

  meta = with stdenv.lib; {
    description = "A library for handling OpenGL function pointer management";
    homepage = https://github.com/anholt/libepoxy;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

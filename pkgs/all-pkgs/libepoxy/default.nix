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
    sha256 = "84676bff4619b55d2c2d277b17868852ab86e1e65069dfcf31bde76b502dea22";
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

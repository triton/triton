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
    version = 1;
    owner = "anholt";
    repo = "libepoxy";
    rev = "v${version}";
    sha256 = "494f0e4ea5e0fa2d785ff3bb0aece4e5e2ef5cfe1b8a85497f6374da14d0f1fa";
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

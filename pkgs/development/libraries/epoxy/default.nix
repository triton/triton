{ stdenv
, autoreconfHook
, fetchFromGitHub
, python

, xorg
, mesa
}:

stdenv.mkDerivation rec {
  name = "epoxy-${version}";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "anholt";
    repo = "libepoxy";
    rev = "v${version}";
    sha256 = "c4d1e31751eafe42504d44b6933967687db9f9fd10c9fa8649cfc19fb9ea3db4";
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

{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
, python

, mesa
, xorg
}:

let
  version = "1.4";
in
stdenv.mkDerivation rec {
  name = "libepoxy-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "anholt";
    repo = "libepoxy";
    rev = "v${version}";
    sha256 = "5db036b788ac1920834fdc6dbee2fe5156d9992f5c7d869b63127a3307ef21c6";
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

  meta = with lib; {
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

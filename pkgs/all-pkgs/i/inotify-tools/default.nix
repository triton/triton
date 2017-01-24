{ stdenv
, autoreconfHook
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "inotify-tools-2014-11-06";

  src = fetchFromGitHub {
    version = 2;
    owner = "rvoicilas";
    repo = "inotify-tools";
    rev = "1df9af4d6cd0f4af4b1b19254bcf056aed4ae395";
    sha256 = "d82dfd75c9403559755555adeca3f742833e7a318956bdf4994ff0ca1f766230";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  postPatch = ''
    sed -i 's, -Werror,,g' src/Makefile.am
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/rvoicilas/inotify-tools/wiki;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

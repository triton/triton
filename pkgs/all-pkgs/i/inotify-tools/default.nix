{ stdenv
, autoreconfHook
, fetchFromGitHub
}:

let
  version = "3.20.1";
in
stdenv.mkDerivation rec {
  name = "inotify-tools-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "rvoicilas";
    repo = "inotify-tools";
    rev = version;
    sha256 = "e107ac8d3e8b9cd1729d35d661b9ec6d0c159aaf15e87852ce44f6b626314039";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

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

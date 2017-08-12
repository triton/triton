{ stdenv
, autoreconfHook
, fetchFromGitHub

, libunwind
}:

stdenv.mkDerivation rec {
  name = "gperftools-2.6.1";

  src = fetchFromGitHub {
    version = 3;
    owner = "gperftools";
    repo = "gperftools";
    rev = name;
    sha256 = "dfe31ac0d98936ab55ed694c04f7b4d52ec90b7be4e18d59b4e76e9054535324";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libunwind
  ];

  # some packages want to link to the static tcmalloc_minimal
  # to drop the runtime dependency on gperftools
  dontDisableStatic = true;

  meta = with stdenv.lib; {
    homepage = https://code.google.com/p/gperftools/;
    description = "Fast, multi-threaded malloc() and nifty performance analysis tools";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

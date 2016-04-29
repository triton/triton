{ stdenv
, autoreconfHook
, fetchFromGitHub

, libunwind
}:

stdenv.mkDerivation rec {
  name = "gperftools-2.5";

  src = fetchFromGitHub {
    owner = "gperftools";
    repo = "gperftools";
    rev = name;
    sha256 = "d7f078bfb62a240a2934c257970effb8ad8e6b744d9b4990f9a050b12f21f9e6";
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

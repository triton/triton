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
    sha256 = "2fb9500166b575f7cc685c23bf4648c292127296ee95881227b55cd2f6ca148e";
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

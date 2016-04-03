{ stdenv
, autoreconfHook
, fetchFromGitHub

, libunwind
}:

stdenv.mkDerivation rec {
  name = "gperftools-2.4.91";

  src = fetchFromGitHub {
    owner = "gperftools";
    repo = "gperftools";
    rev = name;
    sha256 = "6b5e2147a3becdb160d576dd168c01765289512221a8c570a9069c686844935d";
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

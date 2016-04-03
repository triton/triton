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
    sha256 = "1533bc034176a0cef4c1d39ef9987dd518d50385914a788f14320065fa08670e";
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

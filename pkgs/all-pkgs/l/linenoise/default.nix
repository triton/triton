{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation {
  name = "linenoise-2018-07-18";

  src = fetchFromGitHub {
    version = 6;
    owner = "antirez";
    repo = "linenoise";
    rev = "4a961c0108720741e2683868eb10495f015ee422";
    sha256 = "938c04a790668eef049c69708c6c2285830c522eb784b6e10b513893810b9c1e";
  };

  buildPhase = ''
    gcc -o linenoise.o -c linenoise.c
    ar rcs liblinenoise.a linenoise.o
  '';
  
  installPhase = ''
    mkdir -p "$out"/{include,lib}
    mv liblinenoise.a "$out"/lib
    mv linenoise.h "$out"/include
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

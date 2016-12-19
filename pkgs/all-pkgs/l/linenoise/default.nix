{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation {
  name = "linenoise-2016-07-29";

  src = fetchFromGitHub {
    version = 2;
    owner = "antirez";
    repo = "linenoise";
    rev = "c894b9e59f02203dbe4e2be657572cf88c4230c3";
    sha256 = "8e8ed2a742e7e34a87f23ca1f157d04af3ce9fc577020a4834202b7034736177";
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

{ stdenv
, fetchFromGitHub
}:

let
  version = "2.0.2";
in
stdenv.mkDerivation rec {
  name = "uthash-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "troydhanson";
    repo = "uthash";
    rev = "v${version}";
    sha256 = "b091d9a9464e05b934ee7800acc3a9b56ee20f211f5077e361dc38e1400d210b";
  };

  installPhase = ''
    mkdir -p "$out/include"
    cp ./src/* "$out/include/"
  '';

  meta = with stdenv.lib; {
    description = "A hash table for C structures";
    homepage = http://troydhanson.github.io/uthash;
    license = licenses.bsd2; # it's one-clause, actually, as it's source-only
    platforms = with platforms;
      x86_64-linux;
  };
}


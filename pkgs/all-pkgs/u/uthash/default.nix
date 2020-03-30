{ stdenv
, fetchFromGitHub
}:

let
  rev = "1124f0a70b0714886402c3c0df03d037e3c4d57a";
  date = "2019-12-23";
in
stdenv.mkDerivation rec {
  name = "uthash-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "troydhanson";
    repo = "uthash";
    inherit rev;
    sha256 = "e737d9a74ffe1c927df692bc8af43f2ada6a3a8c248a3c74ed220853c1a61f9d";
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


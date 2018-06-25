{ stdenv
, fetchFromGitHub
}:

let
  rev = "49428699aa376f6668d2aedcfa9929480132b66e";
  date = "2018-05-09";
in
stdenv.mkDerivation rec {
  name = "uthash-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "troydhanson";
    repo = "uthash";
    inherit rev;
    sha256 = "71df8dd22626eb1b235fe7fbb06f9d93d63f0a7265b7b0352b96aeb87b68f970";
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


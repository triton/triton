{ stdenv
, fetchFromGitHub
}:

let
  rev = "29fc26a8ee4116236230160b67ae693a11a9352f";
  date = "2018-02-15";
in
stdenv.mkDerivation rec {
  name = "uthash-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "troydhanson";
    repo = "uthash";
    inherit rev;
    sha256 = "aad0a490b6bb075efcea2a1556ac0168c89e587915c89a7e0f89424cf4d44456";
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


{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib

, boost
, zlib
}:

let
  date = "2019-05-11";
in
stdenv.mkDerivation {
  name = "librevenge-${date}";

  # XXX(codyopel): this is my mirror of the sourceforge repo.
  src = fetchFromGitHub {
    version = 6;
    owner = "chlorm-forks";
    repo = "librevenge";
    rev = "819146d9b2f4c064a861d18d5d321f30aab43477";
    multihash = "QmWirB8urRT5vwmXGwDxhJmV78kpQipAiuwuLteLe2eeYt";
    sha256 = "9719b6437146ba3acda04210d4406cbc10b484bf9d2e87fb19f1f1eefe5698d5";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    boost
    zlib
  ];

  configureFlags = [
    "--disable-tests"
  ];

  NIX_CFLAGS_COMPILE = [
    "-std=c++11"
  ];

  meta = with lib; {
    description = "A base library for writing document import filters";
    license = licenses.mpl20 ;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}

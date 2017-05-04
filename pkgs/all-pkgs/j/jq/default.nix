{ stdenv
, autoreconfHook
, fetchFromGitHub

, oniguruma
}:

let
  date = "2017-04-29";
  rev = "6d89e297febdbcbad4ecf201e56fc8ec99f67137";
in
stdenv.mkDerivation rec {
  name = "jq-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "stedolan";
    repo = "jq";
    inherit rev;
    sha256 = "83eb0fe70189f848daf4cf61300825ebf439e0c99dfabab1cd3a8b0139fdf1c1";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    oniguruma
  ];

  configureFlags = [
    "--disable-docs"
  ];

  meta = with stdenv.lib; {
    description = "A lightweight and flexible command-line JSON processor";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

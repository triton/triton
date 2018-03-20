{ stdenv
, autoreconfHook
, fetchFromGitHub

, oniguruma
}:

let
  date = "2018-03-06";
  rev = "c538237f4e4c381d35f1c15497c95f659fd55850";
in
stdenv.mkDerivation rec {
  name = "jq-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "stedolan";
    repo = "jq";
    inherit rev;
    sha256 = "7e74f81b0ad6ef7d007d292f4f6f23d4c33af416f0a7676fefacc991dfb498d4";
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

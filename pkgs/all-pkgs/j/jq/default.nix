{ stdenv
, autoreconfHook
, fetchFromGitHub

, oniguruma
}:

let
  date = "2017-05-21";
  rev = "c538237f4e4c381d35f1c15497c95f659fd55850";
in
stdenv.mkDerivation rec {
  name = "jq-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "stedolan";
    repo = "jq";
    inherit rev;
    sha256 = "542883672416e0a2d4d3735ff520c4504a462768d8aca9e42a10b1c66703fd7b";
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

{ stdenv
, autoreconfHook
, fetchFromGitHub

, oniguruma
}:

let
  date = "2018-08-17";
  rev = "46d1ce2667253f1a34cd389b6d00c0288ab0276f";
in
stdenv.mkDerivation rec {
  name = "jq-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "stedolan";
    repo = "jq";
    inherit rev;
    sha256 = "fe0bd58edda2cd0fb2f4d071d42ce85ff2d1577193647075fd550a289719d5ba";
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

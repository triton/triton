{ stdenv
, lib
, autoreconfHook
, fetchFromGitHub
}:

let
  rev = "60ea749837362c226e8501718f505ab138e5c19d";
  date = "2017-12-25";
in
stdenv.mkDerivation {
  name = "libb2-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "BLAKE2";
    repo = "libb2";
    inherit rev;
    sha256 = "a5cda2c53afc336ed8fb85ac1d6c46c39740b981e30ad60c26cb1ea5cc44d991";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

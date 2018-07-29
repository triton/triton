{ stdenv
, lib
, autoreconfHook
, fetchFromGitHub
}:

let
  rev = "7feb2bb35dfe89750fba62bcd909409e995af754";
  date = "2018-07-11";
in
stdenv.mkDerivation {
  name = "libb2-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "BLAKE2";
    repo = "libb2";
    inherit rev;
    sha256 = "0046d21f26fddccc2a0c135cc20c9d62cfc88225803f4c0c9fb6d7459f15ca63";
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

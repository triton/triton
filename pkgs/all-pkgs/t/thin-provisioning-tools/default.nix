{ stdenv
, autoreconfHook
, fetchFromGitHub

, boost
, expat
, libaio
}:

let
  date = "2017-04-29";
  rev = "b7d418131d0bbfb97ae15b5e886fae56c521e445";
in
stdenv.mkDerivation {
  name = "thin-provisioning-tools-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "jthornber";
    repo = "thin-provisioning-tools";
    inherit rev;
    sha256 = "b187f6975242dee88e9524ce47596eb075cd3fe2362d0a409e61149506fc17e6";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];
  
  buildInputs = [
    boost
    expat
    libaio
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

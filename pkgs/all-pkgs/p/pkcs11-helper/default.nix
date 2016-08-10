{ stdenv
, autoreconfHook
, fetchFromGitHub

, openssl
}:

stdenv.mkDerivation {
  name = "pkcs11-helper-2016-06-11";

  src = fetchFromGitHub {
    owner = "OpenSC";
    repo = "pkcs11-helper";
    rev = "2ccb555deeb22586cf0342e79d6e6142cf95c377";
    sha256 = "f90a234a8fb1bffe88de9460357642b328897609ab70897c38ac0335f94789c7";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    openssl
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

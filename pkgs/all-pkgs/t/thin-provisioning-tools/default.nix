{ stdenv
, autoreconfHook
, fetchFromGitHub

, boost
, expat
, libaio
}:

let
  version = "0.8.3";
in
stdenv.mkDerivation {
  name = "thin-provisioning-tools-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "jthornber";
    repo = "thin-provisioning-tools";
    rev = "v${version}";
    sha256 = "781fd00f64dc05d0f8f14c266e3c636fe3ae85d01ac977f7157c048fa71c2fcb";
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

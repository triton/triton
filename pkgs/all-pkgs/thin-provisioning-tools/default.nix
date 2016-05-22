{ stdenv
, autoreconfHook
, fetchFromGitHub

, boost
, expat
, libaio
}:

let
  version = "0.6.1";
in
stdenv.mkDerivation {
  name = "thin-provisioning-tools-${version}";

  src = fetchFromGitHub {
    owner = "jthornber";
    repo = "thin-provisioning-tools";
    rev = "v${version}";
    sha256 = "93b04e3f460bb346264b7c3a34428244ba1b6777e8ed5952eb217d334fa95230";
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

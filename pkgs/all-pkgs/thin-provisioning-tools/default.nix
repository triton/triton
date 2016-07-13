{ stdenv
, autoreconfHook
, fetchFromGitHub

, boost
, expat
, libaio
}:

let
  version = "0.6.2";
in
stdenv.mkDerivation {
  name = "thin-provisioning-tools-${version}";

  src = fetchFromGitHub {
    owner = "jthornber";
    repo = "thin-provisioning-tools";
    rev = "v${version}";
    sha256 = "bce9e5b91ee777e78e293347764df0118091e6016a97f03f2223f62438ef477c";
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

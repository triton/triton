{ stdenv
, autoreconfHook
, fetchFromGitHub

, boost
, expat
, libaio
}:

let
  version = "0.7.3";
in
stdenv.mkDerivation {
  name = "thin-provisioning-tools-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "jthornber";
    repo = "thin-provisioning-tools";
    rev = "v${version}";
    sha256 = "56f251dfe4de6843622e1ab551f3132a1cfb5e99401e79d5dff0126cd4b2cd0f";
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

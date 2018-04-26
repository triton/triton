{ stdenv
, autoreconfHook
, fetchFromGitHub

, boost
, expat
, libaio
}:

let
  version = "0.7.6";
in
stdenv.mkDerivation {
  name = "thin-provisioning-tools-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "jthornber";
    repo = "thin-provisioning-tools";
    rev = "v${version}";
    sha256 = "4c6774d1822fc96fe62679add44ef6167d6feb48ec807dee9d1fe832ca938118";
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
